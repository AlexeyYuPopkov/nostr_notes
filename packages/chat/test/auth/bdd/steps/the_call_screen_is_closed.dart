import 'package:chat/auth/call/presentation/call/call_screen.dart';
import 'package:flutter_test/flutter_test.dart';

/// Usage: Then the call screen is closed
Future<void> theCallScreenIsClosed(WidgetTester tester) async {
  expect(find.byType(CallScreen), findsNothing);
}
