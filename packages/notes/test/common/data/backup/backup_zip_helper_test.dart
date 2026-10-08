import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_notes/common/data/backup/backup_zip_helper.dart';

void main() {
  const archivedFileName = 'payload.json';

  List<String> entryNames(List<int> zipBytes) =>
      ZipDecoder().decodeBytes(zipBytes).files.map((e) => e.name).toList();

  group('BackupZipHelper', () {
    test('json written to the zip reads back unchanged', () {
      const json = {
        'version': 1,
        'items': [
          {'a': 'b'},
        ],
      };

      final bytes = BackupZipHelper.buildZipBytes(
        json: json,
        archivedFileName: archivedFileName,
        decryptScript: 'print(1)',
        readme: '# readme',
      );

      expect(BackupZipHelper.readJson(bytes, archivedFileName), json);
    });

    test('bundles the decrypt script and readme next to the payload', () {
      final bytes = BackupZipHelper.buildZipBytes(
        json: const {},
        archivedFileName: archivedFileName,
        decryptScript: 'print(1)',
        readme: '# readme',
      );

      expect(
        entryNames(bytes),
        unorderedEquals([
          archivedFileName,
          BackupZipHelper.defaultDecryptScriptName,
          BackupZipHelper.readmeName,
        ]),
      );
    });

    test('uses a custom decrypt script name when given', () {
      final bytes = BackupZipHelper.buildZipBytes(
        json: const {},
        archivedFileName: archivedFileName,
        decryptScript: 'print(1)',
        readme: '# readme',
        decryptScriptName: 'decrypt_keys.py',
      );

      expect(entryNames(bytes), contains('decrypt_keys.py'));
      expect(
        entryNames(bytes),
        isNot(contains(BackupZipHelper.defaultDecryptScriptName)),
      );
    });

    test('readJson is null when the payload entry is missing', () {
      final bytes = BackupZipHelper.buildZipBytes(
        json: const {},
        archivedFileName: 'other.json',
        decryptScript: '',
        readme: '',
      );

      expect(BackupZipHelper.readJson(bytes, archivedFileName), isNull);
    });

    test('readJson is null when the payload is not a JSON object', () {
      final content = utf8.encode('[1, 2]');
      final archive = Archive()
        ..addFile(ArchiveFile(archivedFileName, content.length, content));

      expect(
        BackupZipHelper.readJson(
          ZipEncoder().encode(archive),
          archivedFileName,
        ),
        isNull,
      );
    });

    group('zipFileName', () {
      test('keeps a usable custom name', () {
        expect(
          BackupZipHelper.zipFileName('my keys', defaultPrefix: 'p_'),
          'my keys.zip',
        );
      });

      test('falls back to a timestamped default for a blank name', () {
        final name = BackupZipHelper.zipFileName('  ', defaultPrefix: 'p_');

        expect(name, startsWith('p_'));
        expect(name, endsWith('.zip'));
        expect(name, isNot(contains(':')));
      });
    });
  });
}
