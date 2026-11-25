import 'package:app_test_kit/pump_helpers.dart';
import 'package:chat/auth/call/presentation/incoming_call/incoming_call_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import 'wait_until.dart';

/// Usage: Then the incoming call from {'Alice'} rings
///
/// Waits for the invite to come from the relay and for the caller's profile.
Future<void> theIncomingCallFromRings(
  WidgetTester tester,
  String contact,
) async {
  final screen = find.byType(IncomingCallScreen);
  await waitUntilFound(tester, screen, reason: 'the incoming call screen');
  await waitUntilFound(
    tester,
    find.descendant(of: screen, matching: find.text(contact)),
    reason: 'the name of $contact on the incoming call screen',
  );
  await PumpHelpers.pumpUntilIdle(tester);
}
