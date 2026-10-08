import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../tools/fakes/fake_backup_files.dart';

/// Usage: a notes backup file
Future<void> aNotesBackupFile(WidgetTester tester) async {
  final json = utf8.encode('{"version":1,"encrypted":false,"events":[]}');
  final archive = Archive()
    ..addFile(ArchiveFile('notes_export.json', json.length, json));
  fakeFilePicker.nextFile = (
    path: '',
    bytes: Uint8List.fromList(ZipEncoder().encode(archive)),
  );
}
