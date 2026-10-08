// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './../../bdd_steps/common/a_fresh_install.dart';
import './../../bdd_steps/common/the_app_was_launched_before.dart';
import './../../bdd_steps/keys_backup/fake_file_dialogs.dart';
import './../../bdd_steps/onboarding/i_open_the_onboarding_screen.dart';
import './../../bdd_steps/common/i_tap_text.dart';
import './../../bdd_steps/common/i_see_text.dart';
import './../../bdd_steps/keys_backup/a_key_backup_file_protected_with.dart';
import './../../bdd_steps/keys_backup/i_enter_into_backup_password_field.dart';
import './../../bdd_steps/common/i_see_page.dart';
import './../../bdd_steps/keys_backup/a_notes_backup_file.dart';
import './../../bdd_steps/keys_backup/the_file_picker_is_cancelled.dart';

void main() {
  group('''Sign in with a key backup file''', () {
    Future<void> bddSetUp(WidgetTester tester) async {
      await aFreshInstall(tester);
      await theAppWasLaunchedBefore(tester);
      await fakeFileDialogs(tester);
    }

    testWidgets('''The sign-in page offers loading the key from a file''', (
      tester,
    ) async {
      await bddSetUp(tester);
      await iOpenTheOnboardingScreen(tester);
      await iTapText(tester, 'Get Started');
      await iSeeText(tester, 'Load from File');
    }, tags: ['wip']);
    testWidgets('''A key file with the correct password signs in''', (
      tester,
    ) async {
      await bddSetUp(tester);
      await aKeyBackupFileProtectedWith(tester, '1234');
      await iOpenTheOnboardingScreen(tester);
      await iTapText(tester, 'Get Started');
      await iTapText(tester, 'Load from File');
      await iEnterIntoBackupPasswordField(tester, '1234');
      await iTapText(tester, 'OK');
      await iSeePage(tester, 'Select Relays');
    }, tags: ['wip']);
    testWidgets('''A wrong password keeps the user on the sign-in page''', (
      tester,
    ) async {
      await bddSetUp(tester);
      await aKeyBackupFileProtectedWith(tester, '1234');
      await iOpenTheOnboardingScreen(tester);
      await iTapText(tester, 'Get Started');
      await iTapText(tester, 'Load from File');
      await iEnterIntoBackupPasswordField(tester, '9999');
      await iTapText(tester, 'OK');
      await iSeeText(tester, 'Wrong password, or the backup is corrupted.');
      await iSeePage(tester, 'Enter your Nostr nsec');
    }, tags: ['wip']);
    testWidgets('''A notes backup is not accepted as a key file''', (
      tester,
    ) async {
      await bddSetUp(tester);
      await aNotesBackupFile(tester);
      await iOpenTheOnboardingScreen(tester);
      await iTapText(tester, 'Get Started');
      await iTapText(tester, 'Load from File');
      await iEnterIntoBackupPasswordField(tester, '1234');
      await iTapText(tester, 'OK');
      await iSeeText(tester, 'This file is not a key backup.');
      await iSeePage(tester, 'Enter your Nostr nsec');
    }, tags: ['wip']);
    testWidgets('''Cancelling the file picker keeps the sign-in page''', (
      tester,
    ) async {
      await bddSetUp(tester);
      await theFilePickerIsCancelled(tester);
      await iOpenTheOnboardingScreen(tester);
      await iTapText(tester, 'Get Started');
      await iTapText(tester, 'Load from File');
      await iSeePage(tester, 'Enter your Nostr nsec');
    }, tags: ['wip']);
  });
}
