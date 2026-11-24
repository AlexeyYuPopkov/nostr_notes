// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import './steps/the_user_is_signed_in.dart';
import './steps/wrote_me.dart';
import './steps/calls_never_connect.dart';
import 'package:app_test_kit/bdd_steps/i_close_the_app.dart';
import './steps/i_open_the_chat_with.dart';
import 'package:app_test_kit/bdd_steps/i_tap_semantics.dart';
import './steps/i_am_calling_with.dart';
import 'package:app_test_kit/bdd_steps/i_see_text.dart';
import './steps/the_call_screen_is_closed.dart';
import './steps/the_conversation_shows.dart';

void main() {
  group('''Calls from a chat''', () {
    Future<void> bddSetUp(WidgetTester tester) async {
      await theUserIsSignedIn(tester);
      await wroteMe(tester, 'Alice', 'Hi there');
      await callsNeverConnect(tester);
    }

    Future<void> bddTearDown(WidgetTester tester) async {
      await iCloseTheApp(tester);
    }

    testWidgets('''An audio call rings the contact''', (tester) async {
      try {
        await bddSetUp(tester);
        await iOpenTheChatWith(tester, 'Alice');
        await iTapSemantics(tester, 'ChatScreen.audioCall');
        await iAmCallingWith(tester, 'Alice', 'audio');
        await iSeeText(tester, 'Calling…');
      } finally {
        await bddTearDown(tester);
      }
    });
    testWidgets('''A video call rings the contact''', (tester) async {
      try {
        await bddSetUp(tester);
        await iOpenTheChatWith(tester, 'Alice');
        await iTapSemantics(tester, 'ChatScreen.videoCall');
        await iAmCallingWith(tester, 'Alice', 'video');
      } finally {
        await bddTearDown(tester);
      }
    });
    testWidgets('''Hanging up returns to the chat''', (tester) async {
      try {
        await bddSetUp(tester);
        await iOpenTheChatWith(tester, 'Alice');
        await iTapSemantics(tester, 'ChatScreen.audioCall');
        await iTapSemantics(tester, 'call_view.hang_up');
        await theCallScreenIsClosed(tester);
        await theConversationShows(tester, 'Hi there');
      } finally {
        await bddTearDown(tester);
      }
    });
  });
}
