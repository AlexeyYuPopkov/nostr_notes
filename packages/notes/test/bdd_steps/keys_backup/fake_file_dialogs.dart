import 'dart:io';

import 'package:di_storage/di_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_notes/services/backup_files/backup_file_picker.dart';
import 'package:nostr_notes/services/backup_files/file_share_service.dart';

import '../../tools/fakes/fake_backup_files.dart';

const _pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');

/// Usage: fake file dialogs
Future<void> fakeFileDialogs(WidgetTester tester) async {
  DiStorage.shared
    ..remove<FileShareService>()
    ..remove<BackupFilePicker>()
    ..bind<FileShareService>(
      () => FakeFileShareService(),
      module: null,
      lifeTime: const LifeTime.single(),
    )
    ..bind<BackupFilePicker>(
      () => FakeBackupFilePicker(),
      module: null,
      lifeTime: const LifeTime.single(),
    );

  // Exports write the zip to the temp dir before it is shared.
  final messenger = tester.binding.defaultBinaryMessenger;
  messenger.setMockMethodCallHandler(
    _pathProviderChannel,
    (call) async => call.method == 'getTemporaryDirectory'
        ? Directory.systemTemp.path
        : null,
  );
  addTearDown(
    () => messenger.setMockMethodCallHandler(_pathProviderChannel, null),
  );
}
