// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './steps/the_user_is_signed_in.dart';
import 'package:app_test_kit/bdd_steps/i_close_the_app.dart';
import './steps/i_open_the_authorized_area.dart';
import 'package:app_test_kit/bdd_steps/i_tap_semantics.dart';
import 'package:app_test_kit/bdd_steps/i_see_semantics.dart';
import './steps/wrote_me.dart';
import './steps/the_chat_with_shows.dart';
import './steps/i_open_the_chat_with.dart';

void main() {
  group('''Chats list''', () {
    Future<void> bddSetUp(WidgetTester tester) async {
      await theUserIsSignedIn(tester);
    }

    Future<void> bddTearDown(WidgetTester tester) async {
      await iCloseTheApp(tester);
    }

    testWidgets('''Without chats the list offers to start one''', (
      tester,
    ) async {
      try {
        await bddSetUp(tester);
        await iOpenTheAuthorizedArea(tester);
        await iTapSemantics(tester, 'ChatsListScreen.startChatButton');
        await iSeeSemantics(tester, 'SearchContactScreen.searchField');
      } finally {
        await bddTearDown(tester);
      }
    });
    testWidgets(
      '''A conversation shows the contact's name and the last message''',
      (tester) async {
        try {
          await bddSetUp(tester);
          await wroteMe(tester, 'Alice', 'Hi there');
          await iOpenTheAuthorizedArea(tester);
          await theChatWithShows(tester, 'Alice', 'Hi there');
        } finally {
          await bddTearDown(tester);
        }
      },
    );
    testWidgets('''Tapping a conversation opens it''', (tester) async {
      try {
        await bddSetUp(tester);
        await wroteMe(tester, 'Alice', 'Hi there');
        await iOpenTheChatWith(tester, 'Alice');
        await iSeeSemantics(tester, 'ChatScreen.sendButton');
      } finally {
        await bddTearDown(tester);
      }
    });
  });
}
