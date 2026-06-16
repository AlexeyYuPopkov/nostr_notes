import 'package:di_storage/di_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/app/app_config.dart';
import 'package:nostr_notes/auth/domain/usecase/export_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/import_usecase.dart';
import 'package:nostr_notes/auth/presentation/settings/export_import/bloc/export_import_data.dart';
import 'package:nostr_notes/auth/presentation/settings/export_import/bloc/export_import_event.dart';
import 'package:nostr_notes/auth/presentation/settings/export_import/bloc/export_import_state.dart';
import 'package:nostr_notes/common/domain/usecase/verification_usecase.dart';
import 'package:nostr_notes/services/ads/ads_service.dart';
import 'package:rxdart/rxdart.dart';

final class ExportImportBloc
    extends Bloc<ExportImportEvent, ExportImportState> {
  static const debounceGuard = Duration(milliseconds: 200);
  ExportImportData get data => state.data;

  DiStorage get _di => DiStorage.shared;

  late final ExportUsecase _exportUsecase = _di.resolve();
  late final ImportUsecase _importUsecase = _di.resolve();
  late final VerificationUsecase _verificationUsecase = _di.resolve();
  late final AdsService _adsService = _di.resolve();

  ExportImportBloc()
    : super(ExportImportState.idle(data: ExportImportData.initial())) {
    on<ExportEvent>(_onExport);
    on<ImportEvent>(_onImport);
    on<WillImportEvent>(
      _onWillImportEvent,
      transformer: (events, mapper) =>
          events.throttleTime(debounceGuard).switchMap(mapper),
    );
    on<WillExportEvent>(
      _onWillExportEvent,
      transformer: (events, mapper) =>
          events.throttleTime(debounceGuard).switchMap(mapper),
    );
  }

  Future<void> _onExport(
    ExportEvent event,
    Emitter<ExportImportState> emit,
  ) async {
    emit(ExportImportState.loading(data: data));
    try {
      final (filePath, bytes, fileName) = await _exportUsecase.exportNotes(
        params: ExportParamsAll(
          password: event.password,
          fileName: event.fileName,
        ),
      );
      if (bytes.isEmpty) {
        emit(
          ExportImportState.error(
            data: data,
            error: const ExportError(payload: ExportErrorType.noNotes),
          ),
        );
        return;
      }

      emit(ExportImportState.loading(data: data, progress: 0.9));
      await Future.delayed(const Duration(milliseconds: 700));

      emit(
        ExportImportState.success(
          data: data,
          filePath: filePath,
          bytes: bytes,
          fileName: fileName,
        ),
      );
    } catch (e) {
      emit(ExportImportState.error(data: data, error: e));
    }
  }

  Future<void> _onWillExportEvent(
    WillExportEvent event,
    Emitter<ExportImportState> emit,
  ) async {
    if (AppConfig.showAds) {
      _verificationUsecase.skipNextVerification();
      await _adsService.showInterstitial();
    }
    emit(ExportImportState.willExport(data: data));
  }

  Future<void> _onWillImportEvent(
    WillImportEvent event,
    Emitter<ExportImportState> emit,
  ) async {
    if (AppConfig.showAds) {
      _verificationUsecase.skipNextVerification();
      await _adsService.showInterstitial();
    }
    emit(ExportImportState.willImport(data: data));
  }

  Future<void> _onImport(
    ImportEvent event,
    Emitter<ExportImportState> emit,
  ) async {
    emit(ExportImportState.loading(data: data));
    try {
      final file = event.file;

      if (file == null) {
        emit(
          ExportImportState.error(
            data: data,
            error: const ImportError(payload: ImportErrorType.fileNotFound),
          ),
        );
        return;
      }

      await _importUsecase.importNotes(
        password: event.password,
        filePath: file.path ?? '',
        fileBytes: await file.readAsBytes(),
        policy: event.policy,
      );

      emit(ExportImportState.loading(data: data, progress: 0.9));
      await Future.delayed(const Duration(milliseconds: 700));
      emit(ExportImportState.importSuccess(data: data));
    } catch (e) {
      emit(ExportImportState.error(data: data, error: e));
      rethrow;
    }
  }
}
