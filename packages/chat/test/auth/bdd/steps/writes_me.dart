import 'package:flutter_test/flutter_test.dart';

import 'the_conversation_shows.dart';
import 'wrote_me.dart';

/// Usage: When {'Alice'} writes me {'Are you there?'}
///
/// Like `wrote me`, but while the app is running: the relay pushes it live
/// and the step waits until it is on screen.
Future<void> writesMe(WidgetTester tester, String contact, String text) async {
  await wroteMe(tester, contact, text);
  await theConversationShows(tester, text);
}
