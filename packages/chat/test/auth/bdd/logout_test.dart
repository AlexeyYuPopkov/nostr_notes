// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import './steps/the_user_is_signed_in.dart';
import './steps/my_key_is_saved_on_this_device.dart';
import 'package:app_test_kit/bdd_steps/i_close_the_app.dart';
import './steps/i_open_the_authorized_area.dart';
import 'package:app_test_kit/bdd_steps/i_tap_semantics.dart';
import 'package:app_test_kit/bdd_steps/i_tap_text.dart';
import 'package:app_test_kit/bdd_steps/i_see_text.dart';
import './steps/i_am_signed_out.dart';
import 'package:app_test_kit/bdd_steps/i_see_semantics.dart';
import './steps/i_am_still_signed_in.dart';

void main() {
  group('''Sign out''', () {
    Future<void> bddSetUp(WidgetTester tester) async {
      await theUserIsSignedIn(tester);
      await myKeyIsSavedOnThisDevice(tester);
    }

    Future<void> bddTearDown(WidgetTester tester) async {
      await iCloseTheApp(tester);
    }

    testWidgets('''Signing out returns to the onboarding''', (tester) async {
      try {
        await bddSetUp(tester);
        await iOpenTheAuthorizedArea(tester);
        await iTapSemantics(tester, 'AuthTabs.settings');
        await iTapSemantics(tester, 'SettingsScreen.logoutItem');
        await iTapText(tester, 'OK');
        await iSeeText(tester, 'Welcome to\nEncrypted Chat (Nostr)');
        await iAmSignedOut(tester);
      } finally {
        await bddTearDown(tester);
      }
    });
    testWidgets('''Cancelled sign out keeps the session''', (tester) async {
      try {
        await bddSetUp(tester);
        await iOpenTheAuthorizedArea(tester);
        await iTapSemantics(tester, 'AuthTabs.settings');
        await iTapSemantics(tester, 'SettingsScreen.logoutItem');
        await iTapText(tester, 'Cancel');
        await iSeeSemantics(tester, 'SettingsScreen.logoutItem');
        await iAmStillSignedIn(tester);
      } finally {
        await bddTearDown(tester);
      }
    });
  });
}
