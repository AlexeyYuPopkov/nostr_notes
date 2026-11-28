import 'package:app_test_kit/pump_helpers.dart';
import 'package:chat/auth/call/presentation/incoming_call/incoming_call_screen.dart';
import 'package:flutter_test/flutter_test.dart';

/// Usage: Then the incoming call stops ringing
///
/// Waits for the screen to close, letting the relay's messages arrive.
Future<void> theIncomingCallStopsRinging(WidgetTester tester) async {
  const timeout = Duration(seconds: 10);
  final deadline = DateTime.now().add(timeout);
  while (find.byType(IncomingCallScreen).evaluate().isNotEmpty) {
    if (DateTime.now().isAfter(deadline)) {
      fail('Timed out: the incoming call screen is still open');
    }
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }
  await PumpHelpers.pumpUntilIdle(tester);
}
