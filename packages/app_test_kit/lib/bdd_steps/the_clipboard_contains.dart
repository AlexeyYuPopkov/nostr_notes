import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Usage: the clipboard contains {'text'}
///
/// Needs `a fake clipboard` earlier in the scenario.
Future<void> theClipboardContains(WidgetTester tester, String text) async {
  final data = await Clipboard.getData(Clipboard.kTextPlain);
  expect(data?.text, text);
}
