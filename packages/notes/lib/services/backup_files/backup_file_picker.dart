import 'dart:typed_data';

/// [bytes] is set on web, where there is no file path.
typedef PickedBackupFile = ({String path, Uint8List? bytes});

abstract interface class BackupFilePicker {
  /// Null when the user cancelled.
  Future<PickedBackupFile?> pickZip();
}
