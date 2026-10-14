import 'package:flutter_test/flutter_test.dart';

import 'package:notes_test_kit/fakes/fake_backup_files.dart';

/// Usage: no file was shared
Future<void> noFileWasShared(WidgetTester tester) async {
  expect(fakeFileShare.shared, isEmpty);
}
