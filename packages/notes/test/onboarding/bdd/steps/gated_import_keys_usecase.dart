import 'dart:async';
import 'dart:typed_data';

import 'package:nostr_notes/common/domain/usecase/keys_backup/import_keys_usecase.dart';
import 'package:nostr_notes/common/domain/usecase/keys_backup/key_backup_entry.dart';

/// Holds an import until [release], so a test can see the screen in its
/// loading state — a real in-memory import finishes before any step looks.
final class GatedImportKeysUsecase implements ImportKeysUsecase {
  final ImportKeysUsecase _real;
  final _gate = Completer<void>();

  GatedImportKeysUsecase(this._real);

  void release() {
    if (!_gate.isCompleted) _gate.complete();
  }

  @override
  Future<List<KeyBackupEntry>> importKeys({
    required String password,
    String filePath = '',
    Uint8List? fileBytes,
  }) async {
    await _gate.future;
    return _real.importKeys(
      password: password,
      filePath: filePath,
      fileBytes: fileBytes,
    );
  }
}
