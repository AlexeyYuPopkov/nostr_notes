import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:nostr_notes/auth/presentation/settings/export_import_accounts/bloc/accounts_backup_data.dart';

sealed class AccountsBackupState extends Equatable {
  final AccountsBackupData data;

  const AccountsBackupState({required this.data});

  @override
  List<Object?> get props => [data];

  const factory AccountsBackupState.idle({required AccountsBackupData data}) =
      IdleAccountsState;

  const factory AccountsBackupState.loading({
    required AccountsBackupData data,
    double? progress,
  }) = LoadingAccountsState;

  const factory AccountsBackupState.success({
    required AccountsBackupData data,
    required String filePath,
    required Uint8List bytes,
    required String fileName,
    required int skippedAccounts,
  }) = SuccessAccountsState;

  const factory AccountsBackupState.error({
    required AccountsBackupData data,
    required Object error,
  }) = ErrorAccountsState;

  const factory AccountsBackupState.willImport({
    required AccountsBackupData data,
  }) = WillImportAccountsState;

  const factory AccountsBackupState.willExport({
    required AccountsBackupData data,
  }) = WillExportAccountsState;

  const factory AccountsBackupState.importSuccess({
    required AccountsBackupData data,
    required int skippedAccounts,
  }) = ImportSuccessAccountsState;
}

final class WillExportAccountsState extends AccountsBackupState {
  const WillExportAccountsState({required super.data});

  @override
  bool operator ==(Object other) => identical(this, other);

  @override
  int get hashCode => identityHashCode(this);
}

final class WillImportAccountsState extends AccountsBackupState {
  const WillImportAccountsState({required super.data});

  @override
  bool operator ==(Object other) => identical(this, other);

  @override
  int get hashCode => identityHashCode(this);
}

final class IdleAccountsState extends AccountsBackupState {
  const IdleAccountsState({required super.data});
}

final class LoadingAccountsState extends AccountsBackupState {
  final double? progress;
  const LoadingAccountsState({required super.data, this.progress});

  @override
  List<Object?> get props => [data, progress];
}

final class SuccessAccountsState extends AccountsBackupState {
  final String filePath;
  final Uint8List bytes;
  final String fileName;

  /// Accounts left out of the backup because they could not be decrypted.
  final int skippedAccounts;

  const SuccessAccountsState({
    required super.data,
    required this.filePath,
    required this.bytes,
    required this.fileName,
    required this.skippedAccounts,
  });

  @override
  bool operator ==(Object other) => identical(this, other);

  @override
  int get hashCode => identityHashCode(this);
}

final class ImportSuccessAccountsState extends AccountsBackupState {
  /// Accounts left un-imported because the stored account they collide with
  /// could not be decrypted, and overwriting it would blank a real password.
  final int skippedAccounts;

  const ImportSuccessAccountsState({
    required super.data,
    required this.skippedAccounts,
  });

  @override
  bool operator ==(Object other) => identical(this, other);

  @override
  int get hashCode => identityHashCode(this);
}

final class ErrorAccountsState extends AccountsBackupState {
  final Object error;

  const ErrorAccountsState({required super.data, required this.error});

  @override
  List<Object?> get props => [data, error];
}
