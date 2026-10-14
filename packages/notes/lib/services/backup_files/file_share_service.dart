import 'dart:typed_data';

enum FileShareOutcome { shared, dismissed, unavailable }

/// Hands a backup file to the user: the share sheet on mobile, a save
/// dialog on desktop, a download on web.
abstract interface class FileShareService {
  Future<FileShareOutcome> share({
    required String filePath,
    required Uint8List bytes,
    required String fileName,
  });
}
