import 'package:flutter_test/flutter_test.dart';
import 'package:app_test_kit/pump_helpers.dart';

/// Usage: When I long press {'Hello'} text
Future<void> iLongPressText(WidgetTester tester, String text) async {
  final finder = find.text(text);
  await PumpHelpers.waitFor(tester, finder, reason: '"$text" to long press');
  await tester.longPress(finder.last);
  await PumpHelpers.pumpUntilIdle(tester);
}
