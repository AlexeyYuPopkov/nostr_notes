import 'package:flutter_test/flutter_test.dart';

/// Scrolls the text into view first, as a user would on a long page.
Future<void> iTapText(WidgetTester tester, String text) async {
  final finder = find.text(text);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}
