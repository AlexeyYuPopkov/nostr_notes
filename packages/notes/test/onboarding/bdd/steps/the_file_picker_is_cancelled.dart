import 'package:flutter_test/flutter_test.dart';

import 'package:notes_test_kit/fakes/fake_backup_files.dart';

/// Usage: the file picker is cancelled
Future<void> theFilePickerIsCancelled(WidgetTester tester) async {
  fakeFilePicker.nextFile = null;
}
