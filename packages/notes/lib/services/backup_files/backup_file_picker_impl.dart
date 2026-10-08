import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:nostr_notes/services/backup_files/backup_file_picker.dart';

final class BackupFilePickerImpl implements BackupFilePicker {
  const BackupFilePickerImpl();

  @override
  Future<PickedBackupFile?> pickZip() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );
    if (file == null) return null;

    final path = file.path;
    if (path != null) return (path: path, bytes: null);

    final bytes = await file.readAsByteStream().fold<List<int>>(
      [],
      (buf, chunk) => buf..addAll(chunk),
    );
    return (path: '', bytes: Uint8List.fromList(bytes));
  }
}
