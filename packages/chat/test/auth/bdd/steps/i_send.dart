import 'package:app_test_kit/pump_helpers.dart';
import 'package:chat/auth/chat/presentation/chat/chat_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'the_conversation_shows.dart';

/// Usage: When I send {'Hello'}
Future<void> iSend(WidgetTester tester, String text) async {
  await tester.enterText(
    find.descendant(
      of: find.byKey(ChatScreen.composerKey),
      matching: find.byType(EditableText),
    ),
    text,
  );
  await tester.pump();
  await tester.tap(
    PumpHelpers.findBySemanticsId(ChatScreen.sendButtonSemanticsId),
  );
  await theConversationShows(tester, text);
}
