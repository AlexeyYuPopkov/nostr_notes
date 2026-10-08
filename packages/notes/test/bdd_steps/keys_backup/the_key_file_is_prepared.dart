import 'package:flutter_test/flutter_test.dart';

import '../../tools/fakes/fake_backup_files.dart';

const _timeout = Duration(seconds: 5);
const _pollInterval = Duration(milliseconds: 50);

/// Usage: the key file is prepared
///
/// The export writes the zip to disk, real I/O that never completes inside
/// testWidgets' FakeAsync zone, so wait on the real clock until it reaches
/// the share sheet.
Future<void> theKeyFileIsPrepared(WidgetTester tester) async {
  final deadline = DateTime.now().add(_timeout);
  while (fakeFileShare.shared.isEmpty && DateTime.now().isBefore(deadline)) {
    await tester.runAsync(() => Future<void>.delayed(_pollInterval));
    await tester.pump();
  }
  await tester.pumpAndSettle();
}
