import 'package:flutter_test/flutter_test.dart';
import 'package:notes_test_kit/visible_text_finder.dart';

/// Example: When I see {'text'} text
Future<void> iSeeText(WidgetTester tester, String text) async {
  expect(findVisibleText(text), findsOneWidget);
}
