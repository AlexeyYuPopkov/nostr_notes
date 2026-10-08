import 'package:common/domain/repo/key_tool_repository.dart';
import 'package:di_storage/di_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_notes/common/domain/usecase/keys_backup/export_keys_usecase.dart';
import 'package:nostr_notes/common/domain/usecase/keys_backup/key_backup_entry.dart';

import '../../tools/fakes/fake_backup_files.dart';

/// Usage: a key backup file protected with {'1234'}
Future<void> aKeyBackupFileProtectedWith(
  WidgetTester tester,
  String password,
) async {
  final KeyToolRepository keyTool = DiStorage.shared.resolve();
  final ExportKeysUsecase exportKeys = DiStorage.shared.resolve();
  // PBKDF2 runs on the real clock, not inside testWidgets' FakeAsync zone.
  final file = await tester.runAsync(
    () => exportKeys.exportKeys(
      keys: [KeyBackupEntry(nsec: keyTool.generateNsecKey())],
      password: password,
    ),
  );
  fakeFilePicker.nextFile = (path: '', bytes: file!.bytes);
}
