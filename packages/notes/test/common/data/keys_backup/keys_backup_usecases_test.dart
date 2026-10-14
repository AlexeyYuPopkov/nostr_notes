import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:common/data/repo/key_tool_repository_impl.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr/key_tool/key_tool.dart';
import 'package:nostr_notes/common/data/backup/backup_zip_helper.dart';
import 'package:nostr_notes/common/data/keys_backup/export_keys_usecase_impl.dart';
import 'package:nostr_notes/common/data/keys_backup/import_keys_usecase_impl.dart';
import 'package:nostr_notes/common/domain/usecase/keys_backup/key_backup_entry.dart';
import 'package:nostr_notes/common/domain/usecase/keys_backup/keys_backup_error.dart';

const _password = 'pass1234';
final _bech32Nsec = RegExp(r'nsec1[02-9ac-hj-np-z]{58}');

Matcher _keysBackupError(KeysBackupErrorType type) =>
    isA<KeysBackupError>().having((e) => e.payload, 'payload', type);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (call) async => call.method == 'getTemporaryDirectory'
              ? Directory.systemTemp.path
              : null,
        );
  });

  const keyTool = KeyToolRepositoryImpl();
  const exportSut = ExportKeysUsecaseImpl(keyToolRepository: keyTool);
  const importSut = ImportKeysUsecaseImpl(keyToolRepository: keyTool);

  KeyBackupEntry newKey({String? label}) =>
      KeyBackupEntry(nsec: keyTool.generateNsecKey(), label: label);

  Future<Uint8List> exportBytes(List<KeyBackupEntry> keys) async =>
      (await exportSut.exportKeys(keys: keys, password: _password)).bytes;

  Map<String, Object?> payloadOf(Uint8List zip) =>
      BackupZipHelper.readJson(zip, ExportKeysUsecaseImpl.archivedFileName)!;

  Uint8List zipWith(Map<String, Object?> payload) {
    final bytes = BackupZipHelper.buildZipBytes(
      json: payload,
      archivedFileName: ExportKeysUsecaseImpl.archivedFileName,
      decryptScript: '',
      readme: '',
    );
    return bytes;
  }

  group('ExportKeysUsecaseImpl + ImportKeysUsecaseImpl', () {
    test('a key survives the export/import round trip', () async {
      final key = newKey(label: 'main');

      final imported = await importSut.importKeys(
        password: _password,
        fileBytes: await exportBytes([key]),
      );

      expect(imported, [key]);
    });

    test('several keys survive the round trip in order', () async {
      final keys = [newKey(label: 'a'), newKey(), newKey(label: 'c')];

      final imported = await importSut.importKeys(
        password: _password,
        fileBytes: await exportBytes(keys),
      );

      expect(imported, keys);
    });

    test('import reads the file written to the temp dir', () async {
      final key = newKey();
      final file = await exportSut.exportKeys(keys: [key], password: _password);

      final imported = await importSut.importKeys(
        password: _password,
        filePath: file.filePath,
      );

      expect(imported, [key]);
    });

    test('the archive holds the decrypt script and readme, never a plain '
        'nsec', () async {
      final zip = await exportBytes([newKey()]);
      final archive = ZipDecoder().decodeBytes(zip);

      expect(
        archive.files.map((f) => f.name),
        containsAll([
          ExportKeysUsecaseImpl.archivedFileName,
          ExportKeysUsecaseImpl.decryptScriptName,
          BackupZipHelper.readmeName,
        ]),
      );
      final payloadText = utf8.decode(
        archive.findFile(ExportKeysUsecaseImpl.archivedFileName)!.content
            as List<int>,
      );
      expect(_bech32Nsec.hasMatch(payloadText), isFalse);
    });

    test('the payload exposes the npub so a backup can be identified '
        'without the password', () async {
      final key = newKey();
      final pubkey = keyTool.getUserKeysWithNsec(nsec: key.nsec).publicKey;

      final keys = payloadOf(await exportBytes([key]))['keys']! as List;

      expect((keys.single as Map)['npub'], KeyTool.npubKey(pubkey));
    });

    test('a custom file name is used', () async {
      final file = await exportSut.exportKeys(
        keys: [newKey()],
        password: _password,
        fileName: 'my keys',
      );

      expect(file.fileName, 'my keys.zip');
    });
  });

  group('export errors', () {
    test('a password shorter than the minimum is rejected', () {
      expect(
        exportSut.exportKeys(keys: [newKey()], password: '123'),
        throwsA(_keysBackupError(KeysBackupErrorType.passwordTooShort)),
      );
    });

    test('an empty key list is rejected', () {
      expect(
        exportSut.exportKeys(keys: const [], password: _password),
        throwsA(_keysBackupError(KeysBackupErrorType.noKeys)),
      );
    });

    test('an invalid nsec is rejected', () {
      expect(
        exportSut.exportKeys(
          keys: const [KeyBackupEntry(nsec: 'nsec1garbage')],
          password: _password,
        ),
        throwsA(_keysBackupError(KeysBackupErrorType.invalidKey)),
      );
    });
  });

  group('import errors', () {
    test('a wrong password', () async {
      final zip = await exportBytes([newKey()]);

      expect(
        importSut.importKeys(password: 'wrong-pass', fileBytes: zip),
        throwsA(_keysBackupError(KeysBackupErrorType.wrongPassword)),
      );
    });

    test('bytes that are not a zip', () {
      expect(
        importSut.importKeys(
          password: _password,
          fileBytes: Uint8List.fromList(utf8.encode('garbage')),
        ),
        throwsA(_keysBackupError(KeysBackupErrorType.invalidFile)),
      );
    });

    test('a zip without a keys payload, e.g. a notes backup', () {
      final notesBackup = BackupZipHelper.buildZipBytes(
        json: const {'version': 1, 'encrypted': false, 'events': <Object>[]},
        archivedFileName: 'notes_export.json',
        decryptScript: '',
        readme: '',
      );

      expect(
        importSut.importKeys(password: _password, fileBytes: notesBackup),
        throwsA(_keysBackupError(KeysBackupErrorType.invalidFile)),
      );
    });

    test('a payload of another type', () async {
      final payload = payloadOf(await exportBytes([newKey()]))
        ..['type'] = 'something_else';

      expect(
        importSut.importKeys(password: _password, fileBytes: zipWith(payload)),
        throwsA(_keysBackupError(KeysBackupErrorType.invalidFile)),
      );
    });

    test('a newer format version', () async {
      final payload = payloadOf(await exportBytes([newKey()]))..['version'] = 2;

      expect(
        importSut.importKeys(password: _password, fileBytes: zipWith(payload)),
        throwsA(_keysBackupError(KeysBackupErrorType.unsupportedVersion)),
      );
    });

    test('a payload with no keys', () async {
      final payload = payloadOf(await exportBytes([newKey()]))
        ..['keys'] = <Object>[];

      expect(
        importSut.importKeys(password: _password, fileBytes: zipWith(payload)),
        throwsA(_keysBackupError(KeysBackupErrorType.invalidFile)),
      );
    });

    test('a key whose npub does not match the stored one', () async {
      final first = payloadOf(await exportBytes([newKey()]));
      final second = payloadOf(await exportBytes([newKey()]));
      final firstEntry = (first['keys']! as List).single as Map;
      final secondEntry = (second['keys']! as List).single as Map;
      firstEntry['npub'] = secondEntry['npub'];

      expect(
        importSut.importKeys(password: _password, fileBytes: zipWith(first)),
        throwsA(_keysBackupError(KeysBackupErrorType.invalidKey)),
      );
    });

    test('a missing file', () {
      expect(
        importSut.importKeys(
          password: _password,
          filePath: '${Directory.systemTemp.path}/no_such_backup.zip',
        ),
        throwsA(_keysBackupError(KeysBackupErrorType.invalidFile)),
      );
    });
  });
}
