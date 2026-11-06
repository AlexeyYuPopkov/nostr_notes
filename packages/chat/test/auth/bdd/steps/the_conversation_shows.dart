import 'package:chat/auth/chat/presentation/chat/chat_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import 'wait_until.dart';

/// Text in the open chat, not in the chats list kept under it.
Finder inConversation(String text) =>
    find.descendant(of: find.byType(ChatScreen), matching: find.text(text));

/// Usage: Then the conversation shows {'Hello'}
Future<void> theConversationShows(WidgetTester tester, String text) =>
    waitUntilFound(
      tester,
      inConversation(text),
      reason: '"$text" in the conversation',
    );
