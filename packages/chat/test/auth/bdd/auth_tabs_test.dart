// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './steps/the_user_is_signed_in.dart';
import './steps/a_chat_with.dart';
import './steps/i_open_the_authorized_area.dart';
import 'package:app_test_kit/bdd_steps/i_see_text.dart';
import 'package:app_test_kit/bdd_steps/i_tap_semantics.dart';
import 'package:app_test_kit/bdd_steps/i_tap_text.dart';
import 'package:app_test_kit/bdd_steps/i_see_semantics.dart';
import 'package:app_test_kit/bdd_steps/input_at_first_tf.dart';

void main() {
  group('''Authorized area tabs''', () {
    Future<void> bddSetUp(WidgetTester tester) async {
      await theUserIsSignedIn(tester);
      await aChatWith(tester, 'alice-pubkey');
    }

    testWidgets('''The chats tab opens first and lists the chats''', (
      tester,
    ) async {
      await bddSetUp(tester);
      await iOpenTheAuthorizedArea(tester);
      await iSeeText(tester, 'alice-pubkey');
    });
    testWidgets('''The settings tab shows the settings screen''', (
      tester,
    ) async {
      await bddSetUp(tester);
      await iOpenTheAuthorizedArea(tester);
      await iTapSemantics(tester, 'AuthTabs.settings');
      await iSeeText(tester, 'Settings will appear here');
    });
    testWidgets('''Tapping a chat opens it''', (tester) async {
      await bddSetUp(tester);
      await iOpenTheAuthorizedArea(tester);
      await iTapText(tester, 'alice-pubkey');
      await iSeeSemantics(tester, 'ChatScreen.messageField');
    });
    testWidgets('''A sent message appears in the chat''', (tester) async {
      await bddSetUp(tester);
      await iOpenTheAuthorizedArea(tester);
      await iTapText(tester, 'alice-pubkey');
      await inputAtFirstTf(tester, 'Hello');
      await iTapSemantics(tester, 'ChatScreen.sendButton');
      await iSeeText(tester, 'Hello');
    });
  });
}
