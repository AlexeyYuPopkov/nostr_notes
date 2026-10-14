import 'package:flutter_test/flutter_test.dart';
import 'package:notes_test_kit/visible_text_finder.dart';

/// Example: When I don't see {'text'} text
Future<void> iDontSeeText(WidgetTester tester, String text) async {
  expect(findVisibleText(text), findsNothing);
}
