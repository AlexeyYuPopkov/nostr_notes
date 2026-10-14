import 'package:flutter_test/flutter_test.dart';

/// Usage: I see {'Sign Up with Nostr'} page
///
/// Matches only a title the user can actually reach: AnimatedCrossFade keeps
/// the hidden sign-in/sign-up page in the tree, so a plain find.text sees both.
Future<void> iSeePage(WidgetTester tester, String title) async {
  expect(find.text(title).hitTestable(), findsOneWidget);
}
