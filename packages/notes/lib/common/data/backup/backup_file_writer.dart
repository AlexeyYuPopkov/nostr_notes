import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

abstract final class BackupFileWriter {
  /// Returns the written file's path, or `''` on web, where there is no
  /// file system and callers share the bytes directly.
  static Future<String> writeToTemp(Uint8List bytes, String fileName) async {
    if (kIsWeb) return '';
    final dir = await getTemporaryDirectory();
    await dir.create(recursive: true);
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);
    return file.path;
  }
}
