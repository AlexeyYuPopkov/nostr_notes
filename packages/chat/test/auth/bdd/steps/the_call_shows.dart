import 'package:chat/auth/call/presentation/call/call_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import 'wait_until.dart';

/// Usage: Then the call shows {'Declined'}
///
/// Waits for the call state to reach the screen.
Future<void> theCallShows(WidgetTester tester, String status) async {
  await waitUntilFound(
    tester,
    find.descendant(of: find.byType(CallScreen), matching: find.text(status)),
    reason: 'the call to show "$status"',
  );
}
