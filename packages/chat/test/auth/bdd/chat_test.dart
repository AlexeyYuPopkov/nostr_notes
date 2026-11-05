// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './steps/the_user_is_signed_in.dart';
import './steps/wrote_me.dart';
import 'package:app_test_kit/bdd_steps/i_close_the_app.dart';
import './steps/i_open_the_chat_with.dart';
import './steps/the_conversation_shows.dart';
import './steps/i_send.dart';
import './steps/receives.dart';
import './steps/writes_me.dart';
import 'package:app_test_kit/bdd_steps/i_long_press_text.dart';
import 'package:app_test_kit/bdd_steps/i_tap_semantics.dart';
import 'package:app_test_kit/bdd_steps/i_see_text.dart';
import 'package:app_test_kit/bdd_steps/i_see_semantics.dart';
import 'package:app_test_kit/bdd_steps/i_dont_see_text.dart';

void main() {
  group('''One-to-one chat''', () {
    Future<void> bddSetUp(WidgetTester tester) async {
      await theUserIsSignedIn(tester);
      await wroteMe(tester, 'Alice', 'Hi there');
    }

    Future<void> bddTearDown(WidgetTester tester) async {
      await iCloseTheApp(tester);
    }

    testWidgets('''The conversation shows received messages''', (tester) async {
      try {
        await bddSetUp(tester);
        await iOpenTheChatWith(tester, 'Alice');
        await theConversationShows(tester, 'Hi there');
      } finally {
        await bddTearDown(tester);
      }
    });
    testWidgets('''A sent message reaches the contact''', (tester) async {
      try {
        await bddSetUp(tester);
        await iOpenTheChatWith(tester, 'Alice');
        await iSend(tester, 'Hello');
        await theConversationShows(tester, 'Hello');
        await receives(tester, 'Alice', 'Hello');
      } finally {
        await bddTearDown(tester);
      }
    });
    testWidgets('''A message that arrives while the chat is open is shown''', (
      tester,
    ) async {
      try {
        await bddSetUp(tester);
        await iOpenTheChatWith(tester, 'Alice');
        await writesMe(tester, 'Alice', 'Are you there?');
        await theConversationShows(tester, 'Are you there?');
      } finally {
        await bddTearDown(tester);
      }
    });
    testWidgets('''An edited message shows the new text''', (tester) async {
      try {
        await bddSetUp(tester);
        await iOpenTheChatWith(tester, 'Alice');
        await iSend(tester, 'Helo');
        await iLongPressText(tester, 'Helo');
        await iTapSemantics(tester, 'MessageActionsSheet.edit');
        await iSend(tester, 'Hello');
        await theConversationShows(tester, 'Hello');
        await iSeeText(tester, 'edited');
        await receives(tester, 'Alice', 'Hello');
      } finally {
        await bddTearDown(tester);
      }
    });
    testWidgets('''The contact's message can be copied but not edited''', (
      tester,
    ) async {
      try {
        await bddSetUp(tester);
        await iOpenTheChatWith(tester, 'Alice');
        await iLongPressText(tester, 'Hi there');
        await iSeeSemantics(tester, 'MessageActionsSheet.copy');
        await iDontSeeText(tester, 'Edit');
      } finally {
        await bddTearDown(tester);
      }
    });
  });
}
