import 'dart:typed_data';

import 'package:nostr_notes/common/domain/usecase/keys_backup/key_backup_entry.dart';

abstract interface class ImportKeysUsecase {
  /// Never returns an empty list: a backup without keys is
  /// `KeysBackupErrorType.invalidFile`.
  Future<List<KeyBackupEntry>> importKeys({
    required String password,
    String filePath = '',
    Uint8List? fileBytes,
  });
}
