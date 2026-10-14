// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:common/presentation/widgets/progress_hud/progress_hud.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:notes_test_kit/bdd_steps/a_fresh_install.dart';
import 'package:notes_test_kit/bdd_steps/the_app_was_launched_before.dart';
import 'package:notes_test_kit/bdd_steps/fake_file_dialogs.dart';
import './steps/i_open_the_onboarding_screen.dart';
import 'package:notes_test_kit/bdd_steps/i_tap_text.dart';
import 'package:notes_test_kit/bdd_steps/i_see_text.dart';
import './steps/a_key_backup_file_protected_with.dart';
import './steps/the_key_import_waits_until_released.dart';
import 'package:notes_test_kit/bdd_steps/i_enter_into_backup_password_field.dart';
import 'package:notes_test_kit/bdd_steps/i_see_semantics.dart';
import './steps/the_key_import_is_released.dart';
import 'package:notes_test_kit/bdd_steps/i_see_page.dart';
import './steps/a_notes_backup_file.dart';
import './steps/the_file_picker_is_cancelled.dart';

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
    });
    testWidgets('''A key file with the correct password signs in''', (
      tester,
    ) async {
      await bddSetUp(tester);
      await aKeyBackupFileProtectedWith(tester, '1234');
      await theKeyImportWaitsUntilReleased(tester);
      await iOpenTheOnboardingScreen(tester);
      await iTapText(tester, 'Get Started');
      await iTapText(tester, 'Load from File');
      await iEnterIntoBackupPasswordField(tester, '1234');
      await iTapText(tester, 'OK');
      await iSeeSemantics(tester, ProgressHud.semanticsId);
      await theKeyImportIsReleased(tester);
      await iSeePage(tester, 'Select Relays');
    });
    testWidgets('''A wrong password keeps the user on the sign-in page''', (
      tester,
    ) async {
      await bddSetUp(tester);
      await aKeyBackupFileProtectedWith(tester, '1234');
      await theKeyImportWaitsUntilReleased(tester);
      await iOpenTheOnboardingScreen(tester);
      await iTapText(tester, 'Get Started');
      await iTapText(tester, 'Load from File');
      await iEnterIntoBackupPasswordField(tester, '9999');
      await iTapText(tester, 'OK');
      await iSeeSemantics(tester, ProgressHud.semanticsId);
      await theKeyImportIsReleased(tester);
      await iSeeText(tester, 'Wrong password, or the backup is corrupted.');
      await iSeePage(tester, 'Enter your Nostr nsec');
    });
    testWidgets('''A notes backup is not accepted as a key file''', (
      tester,
    ) async {
      await bddSetUp(tester);
      await aNotesBackupFile(tester);
      await iOpenTheOnboardingScreen(tester);
      await iTapText(tester, 'Get Started');
      await iTapText(tester, 'Load from File');
      await iEnterIntoBackupPasswordField(tester, '1234');
      await theKeyImportWaitsUntilReleased(tester);
      await iTapText(tester, 'OK');
      await iSeeSemantics(tester, ProgressHud.semanticsId);
      await theKeyImportIsReleased(tester);
      await iSeeText(tester, 'This file is not a key backup.');
      await iSeePage(tester, 'Enter your Nostr nsec');
    });
    testWidgets('''Cancelling the file picker keeps the sign-in page''', (
      tester,
    ) async {
      await bddSetUp(tester);
      await theFilePickerIsCancelled(tester);
      await iOpenTheOnboardingScreen(tester);
      await iTapText(tester, 'Get Started');
      await iTapText(tester, 'Load from File');
      await iSeePage(tester, 'Enter your Nostr nsec');
    });
  });
}
