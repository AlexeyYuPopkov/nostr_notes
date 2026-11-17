// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './steps/the_user_is_signed_in.dart';
import './steps/a_contact_named_can_be_found.dart';
import 'package:app_test_kit/bdd_steps/i_close_the_app.dart';
import './steps/i_open_the_authorized_area.dart';
import 'package:app_test_kit/bdd_steps/i_tap_semantics.dart';
import 'package:app_test_kit/bdd_steps/i_see_text.dart';
import './steps/i_search_for.dart';
import 'package:app_test_kit/bdd_steps/i_tap_text.dart';
import 'package:app_test_kit/bdd_steps/i_see_semantics.dart';
import 'package:app_test_kit/bdd_steps/i_dont_see_text.dart';

void main() {
  group('''Search for a contact to chat with''', () {
    Future<void> bddSetUp(WidgetTester tester) async {
      await theUserIsSignedIn(tester);
      await aContactNamedCanBeFound(tester, 'Alice');
    }

    Future<void> bddTearDown(WidgetTester tester) async {
      await iCloseTheApp(tester);
    }

    testWidgets('''The search opens from the chats list''', (tester) async {
      try {
        await bddSetUp(tester);
        await iOpenTheAuthorizedArea(tester);
        await iTapSemantics(tester, 'ChatsListScreen.searchContactButton');
        await iSeeText(tester, 'Search people by name, npub or public key');
      } finally {
        await bddTearDown(tester);
      }
    });
    testWidgets('''A matching contact is listed with its name''', (
      tester,
    ) async {
      try {
        await bddSetUp(tester);
        await iOpenTheAuthorizedArea(tester);
        await iTapSemantics(tester, 'ChatsListScreen.searchContactButton');
        await iSearchFor(tester, 'ali');
        await iSeeText(tester, 'Alice');
      } finally {
        await bddTearDown(tester);
      }
    });
    testWidgets('''Nothing matches''', (tester) async {
      try {
        await bddSetUp(tester);
        await iOpenTheAuthorizedArea(tester);
        await iTapSemantics(tester, 'ChatsListScreen.searchContactButton');
        await iSearchFor(tester, 'zzz');
        await iSeeText(tester, 'No users found');
      } finally {
        await bddTearDown(tester);
      }
    });
    testWidgets('''Tapping a contact replaces the search with the chat''', (
      tester,
    ) async {
      try {
        await bddSetUp(tester);
        await iOpenTheAuthorizedArea(tester);
        await iTapSemantics(tester, 'ChatsListScreen.searchContactButton');
        await iSearchFor(tester, 'ali');
        await iTapText(tester, 'Alice');
        await iSeeSemantics(tester, 'ChatScreen.sendButton');
        await iDontSeeText(tester, 'New chat');
      } finally {
        await bddTearDown(tester);
      }
    });
    testWidgets('''Closing the search returns to the chats list''', (
      tester,
    ) async {
      try {
        await bddSetUp(tester);
        await iOpenTheAuthorizedArea(tester);
        await iTapSemantics(tester, 'ChatsListScreen.searchContactButton');
        await iTapSemantics(tester, 'SearchContactScreen.closeButton');
        await iSeeSemantics(tester, 'ChatsListScreen.searchContactButton');
        await iDontSeeText(tester, 'New chat');
      } finally {
        await bddTearDown(tester);
      }
    });
  });
}
