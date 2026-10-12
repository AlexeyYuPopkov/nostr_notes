import 'package:equatable/equatable.dart';
import 'package:nostr_notes/auth/presentation/settings/export_import_keys/bloc/keys_backup_data.dart';
import 'package:nostr_notes/common/domain/usecase/keys_backup/export_keys_usecase.dart';

sealed class KeysBackupState extends Equatable {
  final KeysBackupData data;

  const KeysBackupState({required this.data});

  @override
  List<Object?> get props => [data];

  const factory KeysBackupState.idle({required KeysBackupData data}) =
      IdleKeysState;

  const factory KeysBackupState.loading({required KeysBackupData data}) =
      LoadingKeysState;

  const factory KeysBackupState.exported({
    required KeysBackupData data,
    required KeysBackupFile file,
  }) = ExportedKeysState;

  const factory KeysBackupState.error({
    required KeysBackupData data,
    required Object error,
  }) = ErrorKeysState;
}

final class IdleKeysState extends KeysBackupState {
  const IdleKeysState({required super.data});
}

final class LoadingKeysState extends KeysBackupState {
  const LoadingKeysState({required super.data});
}

/// The encrypted key file is built and waits to be shared or saved.
final class ExportedKeysState extends KeysBackupState {
  final KeysBackupFile file;

  const ExportedKeysState({required super.data, required this.file});

  @override
  List<Object?> get props => [data, file.fileName, file.bytes];
}

final class ErrorKeysState extends KeysBackupState {
  final Object error;

  const ErrorKeysState({required super.data, required this.error});

  @override
  List<Object?> get props => [data, error];
}
