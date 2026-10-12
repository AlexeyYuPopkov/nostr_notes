import 'package:di_storage/di_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/auth/domain/usecase/credentials_data_usecase.dart';
import 'package:nostr_notes/auth/presentation/settings/export_import_keys/bloc/keys_backup_data.dart';
import 'package:nostr_notes/auth/presentation/settings/export_import_keys/bloc/keys_backup_event.dart';
import 'package:nostr_notes/auth/presentation/settings/export_import_keys/bloc/keys_backup_state.dart';
import 'package:nostr_notes/common/domain/usecase/keys_backup/export_keys_usecase.dart';
import 'package:nostr_notes/common/domain/usecase/keys_backup/key_backup_entry.dart';

final class KeysBackupBloc extends Bloc<KeysBackupEvent, KeysBackupState> {
  KeysBackupData get data => state.data;

  DiStorage get _di => DiStorage.shared;

  late final ExportKeysUsecase _exportKeysUsecase = _di.resolve();
  late final _credentialsDataUsecase = CredentialsDataUsecase(
    session: _di.resolve(),
  );

  KeysBackupBloc()
    : super(KeysBackupState.idle(data: KeysBackupData.initial())) {
    on<ExportKeyEvent>(_onExport);
  }

  Future<void> _onExport(
    ExportKeyEvent event,
    Emitter<KeysBackupState> emit,
  ) async {
    emit(KeysBackupState.loading(data: data));
    try {
      final credentials = await _credentialsDataUsecase.execute();
      final file = await _exportKeysUsecase.exportKeys(
        keys: [KeyBackupEntry(nsec: credentials.nsec)],
        password: event.password,
        fileName: event.fileName,
      );
      emit(KeysBackupState.exported(data: data, file: file));
    } catch (e) {
      emit(KeysBackupState.error(data: data, error: e));
    }
  }
}
