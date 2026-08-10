import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:nostr_notes/auth/data/models/backup_payload.dart';

/// ZIP packaging shared by every backup export/import usecase — the payload
/// JSON under a content-specific entry name, plus a matching README/decrypt
/// script pair so the archive is self-describing without the app.
abstract final class BackupZipHelper {
  static Uint8List buildZipBytes({
    required BackupPayload payload,
    required String archivedFileName,
    required String decryptScript,
    required String readme,
  }) {
    final jsonBytes = utf8.encode(
      const JsonEncoder.withIndent('  ').convert(payload.toJson()),
    );
    final archive = Archive()
      ..addFile(ArchiveFile(archivedFileName, jsonBytes.length, jsonBytes));

    _addTextFile(archive, 'decrypt_backup.py', decryptScript);
    _addTextFile(archive, 'BACKUP_README.md', readme);

    return Uint8List.fromList(ZipEncoder().encode(archive));
  }

  static void _addTextFile(Archive archive, String name, String content) {
    final bytes = utf8.encode(content);
    archive.addFile(ArchiveFile(name, bytes.length, bytes));
  }

  /// Null if [archivedFileName] isn't present in the archive.
  static BackupPayload? readPayload(List<int> bytes, String archivedFileName) {
    final archive = ZipDecoder().decodeBytes(bytes);
    final jsonFile = archive.findFile(archivedFileName);
    if (jsonFile == null) return null;

    return BackupPayload.fromJson(
      jsonDecode(utf8.decode(jsonFile.content as List<int>))
          as Map<String, dynamic>,
    );
  }

  /// Returns a safe base file name (no extension) from user input, or null
  /// to fall back to a default. Strips path separators, characters illegal
  /// in file names and leading dots so the name can never escape the temp
  /// dir it's written into.
  static String? sanitizeFileName(String? raw, {int maxLength = 64}) {
    if (raw == null) return null;
    var name = raw.trim();
    if (name.isEmpty) return null;

    if (name.toLowerCase().endsWith('.zip')) {
      name = name.substring(0, name.length - 4);
    }

    name = name
        .replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1f]'), '')
        .replaceAll(RegExp(r'^\.+'), '')
        .trim();
    if (name.isEmpty) return null;

    if (name.length > maxLength) name = name.substring(0, maxLength);
    return name;
  }
}
