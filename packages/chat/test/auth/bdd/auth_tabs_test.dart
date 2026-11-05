// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './steps/the_user_is_signed_in.dart';
import 'package:app_test_kit/bdd_steps/i_close_the_app.dart';
import './steps/i_open_the_authorized_area.dart';
import 'package:app_test_kit/bdd_steps/i_see_text.dart';
import 'package:app_test_kit/bdd_steps/i_tap_semantics.dart';
import 'package:app_test_kit/bdd_steps/i_see_semantics.dart';

void main() {
  group('''Authorized area tabs''', () {
    Future<void> bddSetUp(WidgetTester tester) async {
      await theUserIsSignedIn(tester);
    }

    Future<void> bddTearDown(WidgetTester tester) async {
      await iCloseTheApp(tester);
    }

    testWidgets('''The chats tab opens first''', (tester) async {
      try {
        await bddSetUp(tester);
        await iOpenTheAuthorizedArea(tester);
        await iSeeText(tester, 'No chats yet');
      } finally {
        await bddTearDown(tester);
      }
    });
    testWidgets('''The settings tab shows the settings screen''', (
      tester,
    ) async {
      try {
        await bddSetUp(tester);
        await iOpenTheAuthorizedArea(tester);
        await iTapSemantics(tester, 'AuthTabs.settings');
        await iSeeSemantics(tester, 'SettingsScreen.profileItem');
      } finally {
        await bddTearDown(tester);
      }
    });
  });
}
