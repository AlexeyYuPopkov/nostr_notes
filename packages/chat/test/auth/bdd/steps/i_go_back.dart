import 'package:app_test_kit/pump_helpers.dart';
import 'package:flutter_test/flutter_test.dart';

/// Usage: And I go back
///
/// Taps the app bar's back button, as a user leaving the screen would.
Future<void> iGoBack(WidgetTester tester) async {
  await tester.pageBack();
  await PumpHelpers.pumpUntilIdle(tester);
}
