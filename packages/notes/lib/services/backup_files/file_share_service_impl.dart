import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:nostr_notes/services/backup_files/file_share_service.dart';
import 'package:share_plus/share_plus.dart';

final class FileShareServiceImpl implements FileShareService {
  const FileShareServiceImpl();

  @override
  Future<FileShareOutcome> share({
    required String filePath,
    required Uint8List bytes,
    required String fileName,
  }) async {
    if (!kIsWeb && _isDesktop) {
      return _saveFileDesktop(bytes, fileName);
    }

    final xFile = kIsWeb
        ? XFile.fromData(bytes, name: fileName, mimeType: 'application/zip')
        : XFile(filePath);
    final result = await SharePlus.instance.share(ShareParams(files: [xFile]));

    return switch (result.status) {
      ShareResultStatus.success => FileShareOutcome.shared,
      ShareResultStatus.dismissed => FileShareOutcome.dismissed,
      ShareResultStatus.unavailable => FileShareOutcome.unavailable,
    };
  }

  bool get _isDesktop =>
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux;

  Future<FileShareOutcome> _saveFileDesktop(
    Uint8List bytes,
    String fileName,
  ) async {
    final savedPath = await FilePicker.saveFile(
      fileName: fileName,
      bytes: bytes,
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );
    return savedPath == null
        ? FileShareOutcome.dismissed
        : FileShareOutcome.shared;
  }
}
