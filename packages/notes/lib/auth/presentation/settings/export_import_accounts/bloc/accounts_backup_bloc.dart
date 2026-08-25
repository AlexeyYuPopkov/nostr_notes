import 'dart:io';
import 'dart:typed_data';

import 'package:di_storage/di_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/app/app_config.dart';
import 'package:nostr_notes/auth/domain/usecase/login_items/export_accounts_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/login_items/import_accounts_usecase.dart';
import 'package:nostr_notes/auth/presentation/settings/export_import_accounts/bloc/accounts_backup_data.dart';
import 'package:nostr_notes/auth/presentation/settings/export_import_accounts/bloc/accounts_backup_event.dart';
import 'package:nostr_notes/auth/presentation/settings/export_import_accounts/bloc/accounts_backup_state.dart';
import 'package:nostr_notes/common/domain/usecase/verification_usecase.dart';
import 'package:nostr_notes/services/ads/ads_service.dart';
import 'package:rxdart/rxdart.dart';

/// Mirrors `ExportImportBloc` (notes) — separate bloc entirely, per the
/// login-items feature's existing precedent of not sharing state machines
/// with the notes side (see `AccsBloc`). The only behavioral difference is
/// upstream: [ExportAccountsUsecase]/[ImportAccountsUsecase] require a
/// non-empty password, so [ExportAccountsErrorType.passwordRequired] /
/// [ImportAccountsErrorType.passwordRequired] are real error states here.
final class AccountsBackupBloc
    extends Bloc<AccountsBackupEvent, AccountsBackupState> {
  static const debounceGuard = Duration(milliseconds: 200);
  AccountsBackupData get data => state.data;

  DiStorage get _di => DiStorage.shared;

  late final ExportAccountsUsecase _exportUsecase = _di.resolve();
  late final ImportAccountsUsecase _importUsecase = _di.resolve();
  late final VerificationUsecase _verificationUsecase = _di.resolve();
  late final AdsService _adsService = _di.resolve();

  AccountsBackupBloc()
    : super(AccountsBackupState.idle(data: AccountsBackupData.initial())) {
    on<ExportAccountsEvent>(_onExport);
    on<ImportAccountsEvent>(_onImport);
    on<WillImportAccountsEvent>(
      _onWillImportEvent,
      transformer: (events, mapper) =>
          events.throttleTime(debounceGuard).switchMap(mapper),
    );
    on<WillExportAccountsEvent>(
      _onWillExportEvent,
      transformer: (events, mapper) =>
          events.throttleTime(debounceGuard).switchMap(mapper),
    );
  }

  Future<void> _onExport(
    ExportAccountsEvent event,
    Emitter<AccountsBackupState> emit,
  ) async {
    emit(AccountsBackupState.loading(data: data));
    try {
      final (filePath, bytes, fileName) = await _exportUsecase.exportAccounts(
        password: event.password,
        fileName: event.fileName,
      );
      if (bytes.isEmpty) {
        emit(
          AccountsBackupState.error(
            data: data,
            error: const ExportAccountsError(
              payload: ExportAccountsErrorType.noAccounts,
            ),
          ),
        );
        return;
      }

      emit(AccountsBackupState.loading(data: data, progress: 0.9));
      await Future.delayed(const Duration(milliseconds: 700));

      emit(
        AccountsBackupState.success(
          data: data,
          filePath: filePath,
          bytes: bytes,
          fileName: fileName,
        ),
      );
    } catch (e) {
      emit(AccountsBackupState.error(data: data, error: e));
    }
  }

  Future<void> _onWillExportEvent(
    WillExportAccountsEvent event,
    Emitter<AccountsBackupState> emit,
  ) async {
    if (AppConfig.showAds) {
      _verificationUsecase.skipNextVerification();
      await _adsService.showInterstitial();
    }
    emit(AccountsBackupState.willExport(data: data));
  }

  Future<void> _onWillImportEvent(
    WillImportAccountsEvent event,
    Emitter<AccountsBackupState> emit,
  ) async {
    if (AppConfig.showAds) {
      _verificationUsecase.skipNextVerification();
      await _adsService.showInterstitial();
    }
    emit(AccountsBackupState.willImport(data: data));
  }

  Future<void> _onImport(
    ImportAccountsEvent event,
    Emitter<AccountsBackupState> emit,
  ) async {
    emit(AccountsBackupState.loading(data: data));
    try {
      final file = event.file;

      if (file == null) {
        emit(
          AccountsBackupState.error(
            data: data,
            error: const ImportAccountsError(
              payload: ImportAccountsErrorType.fileNotFound,
            ),
          ),
        );
        return;
      }

      await _importUsecase.importAccounts(
        password: event.password,
        filePath: file.path ?? '',
        fileBytes: file.path != null
            ? await File(file.path!).readAsBytes()
            : await file
                  .readAsByteStream()
                  .fold<List<int>>([], (buf, chunk) => buf..addAll(chunk))
                  .then(Uint8List.fromList),
        policy: event.policy,
      );

      emit(AccountsBackupState.loading(data: data, progress: 0.9));
      await Future.delayed(const Duration(milliseconds: 700));
      emit(AccountsBackupState.importSuccess(data: data));
    } catch (e) {
      emit(AccountsBackupState.error(data: data, error: e));
    }
  }
}
