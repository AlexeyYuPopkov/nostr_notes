import 'dart:typed_data';

import 'package:nostr_notes/common/domain/usecase/keys_backup/key_backup_entry.dart';

/// On web [filePath] is empty; callers must use [bytes] + [fileName] instead.
typedef KeysBackupFile = ({String filePath, Uint8List bytes, String fileName});

abstract interface class ExportKeysUsecase {
  static const minPasswordLength = 4;

  /// Unlike a notes backup there is no unencrypted mode: the file holds
  /// directly usable private keys.
  Future<KeysBackupFile> exportKeys({
    required List<KeyBackupEntry> keys,
    required String password,
    String? fileName,
  });
}
