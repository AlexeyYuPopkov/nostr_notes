import 'package:flutter_test/flutter_test.dart';

import '../../tools/fakes/fake_backup_files.dart';

/// Usage: no file was shared
Future<void> noFileWasShared(WidgetTester tester) async {
  expect(fakeFileShare.shared, isEmpty);
}
