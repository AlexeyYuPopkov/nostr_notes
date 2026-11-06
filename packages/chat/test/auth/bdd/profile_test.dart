// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './steps/the_user_is_signed_in.dart';
import './steps/my_profile_is_named.dart';
import 'package:app_test_kit/bdd_steps/i_close_the_app.dart';
import './steps/i_open_the_authorized_area.dart';
import 'package:app_test_kit/bdd_steps/i_tap_semantics.dart';
import 'package:app_test_kit/bdd_steps/i_see_text.dart';
import './steps/i_open_my_profile.dart';
import 'package:app_test_kit/bdd_steps/i_enter_into_semantics.dart';
import './steps/my_saved_name_is.dart';
import './steps/no_relay_accepts_my_profile.dart';
import 'package:app_test_kit/bdd_steps/a_fake_clipboard.dart';
import 'package:app_test_kit/bdd_steps/the_clipboard_contains.dart';

void main() {
  group('''Edit my profile''', () {
    Future<void> bddSetUp(WidgetTester tester) async {
      await theUserIsSignedIn(tester);
      await myProfileIsNamed(tester, 'Alice');
    }

    Future<void> bddTearDown(WidgetTester tester) async {
      await iCloseTheApp(tester);
    }

    testWidgets('''The profile opens from the settings''', (tester) async {
      try {
        await bddSetUp(tester);
        await iOpenTheAuthorizedArea(tester);
        await iTapSemantics(tester, 'AuthTabs.settings');
        await iTapSemantics(tester, 'SettingsScreen.profileItem');
        await iSeeText(tester, 'Alice');
      } finally {
        await bddTearDown(tester);
      }
    });
    testWidgets('''A malformed picture link is rejected''', (tester) async {
      try {
        await bddSetUp(tester);
        await iOpenMyProfile(tester);
        await iEnterIntoSemantics(
          tester,
          'not a link',
          'ProfileScreen.pictureField',
        );
        await iSeeText(
          tester,
          'Enter a full link starting with https:// or http://',
        );
      } finally {
        await bddTearDown(tester);
      }
    });
    testWidgets('''A profile with a malformed picture link is not saved''', (
      tester,
    ) async {
      try {
        await bddSetUp(tester);
        await iOpenMyProfile(tester);
        await iEnterIntoSemantics(tester, 'Bob', 'ProfileScreen.nameField');
        await iEnterIntoSemantics(
          tester,
          'not a link',
          'ProfileScreen.pictureField',
        );
        await iTapSemantics(tester, 'ProfileScreen.saveButton');
        await iSeeText(
          tester,
          'Enter a full link starting with https:// or http://',
        );
        await mySavedNameIs(tester, 'Alice');
      } finally {
        await bddTearDown(tester);
      }
    });
    testWidgets('''A saved name is kept''', (tester) async {
      try {
        await bddSetUp(tester);
        await iOpenMyProfile(tester);
        await iEnterIntoSemantics(tester, 'Bob', 'ProfileScreen.nameField');
        await iTapSemantics(tester, 'ProfileScreen.saveButton');
        await iSeeText(tester, 'Profile saved');
        await mySavedNameIs(tester, 'Bob');
      } finally {
        await bddTearDown(tester);
      }
    });
    testWidgets('''A profile no relay accepted stays on the device''', (
      tester,
    ) async {
      try {
        await bddSetUp(tester);
        await noRelayAcceptsMyProfile(tester);
        await iOpenMyProfile(tester);
        await iEnterIntoSemantics(tester, 'Bob', 'ProfileScreen.nameField');
        await iTapSemantics(tester, 'ProfileScreen.saveButton');
        await iSeeText(
          tester,
          'Saved on this device, but no relay accepted it',
        );
        await mySavedNameIs(tester, 'Bob');
      } finally {
        await bddTearDown(tester);
      }
    });
    testWidgets('''My public keys are shown''', (tester) async {
      try {
        await bddSetUp(tester);
        await iOpenMyProfile(tester);
        await iSeeText(
          tester,
          'npub1sg6plzptd64u62a878hep2kev88swjh3tw00gjsfl8f237lmu63q0uf63m',
        );
        await iSeeText(
          tester,
          '82341f882b6eabcd2ba7f1ef90aad961cf074af15b9ef44a09f9d2a8fbfbe6a2',
        );
      } finally {
        await bddTearDown(tester);
      }
    });
    testWidgets('''The npub can be copied''', (tester) async {
      try {
        await bddSetUp(tester);
        await aFakeClipboard(tester);
        await iOpenMyProfile(tester);
        await iTapSemantics(tester, 'ProfileScreen.npubCopyButton');
        await theClipboardContains(
          tester,
          'npub1sg6plzptd64u62a878hep2kev88swjh3tw00gjsfl8f237lmu63q0uf63m',
        );
      } finally {
        await bddTearDown(tester);
      }
    });
    testWidgets('''The hex public key can be copied''', (tester) async {
      try {
        await bddSetUp(tester);
        await aFakeClipboard(tester);
        await iOpenMyProfile(tester);
        await iTapSemantics(tester, 'ProfileScreen.pubkeyCopyButton');
        await theClipboardContains(
          tester,
          '82341f882b6eabcd2ba7f1ef90aad961cf074af15b9ef44a09f9d2a8fbfbe6a2',
        );
      } finally {
        await bddTearDown(tester);
      }
    });
  });
}
