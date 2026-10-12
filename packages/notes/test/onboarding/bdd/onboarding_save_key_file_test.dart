// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:notes_test_kit/bdd_steps/a_fresh_install.dart';
import 'package:notes_test_kit/bdd_steps/fake_file_dialogs.dart';
import './steps/i_open_the_onboarding_screen.dart';
import 'package:notes_test_kit/bdd_steps/i_tap_text.dart';
import 'package:notes_test_kit/bdd_steps/i_see_text.dart';
import 'package:notes_test_kit/bdd_steps/i_enter_into_backup_password_field.dart';
import 'package:notes_test_kit/bdd_steps/no_file_was_shared.dart';
import 'package:notes_test_kit/bdd_steps/the_key_file_is_prepared.dart';
import 'package:notes_test_kit/bdd_steps/a_key_backup_zip_was_shared.dart';
import 'package:notes_test_kit/bdd_steps/i_see_page.dart';

void main() {
  group('''Save the generated key to a file''', () {
    Future<void> bddSetUp(WidgetTester tester) async {
      await aFreshInstall(tester);
      await fakeFileDialogs(tester);
      await iOpenTheOnboardingScreen(tester);
      await iTapText(tester, 'Get Started');
      await iTapText(tester, 'Generate a Nostr Key');
    }

    testWidgets('''The generated key can be saved to a file''', (tester) async {
      await bddSetUp(tester);
      await iSeeText(tester, 'Save');
    });
    testWidgets('''The backup password must be at least 4 characters''', (
      tester,
    ) async {
      await bddSetUp(tester);
      await iTapText(tester, 'Save');
      await iEnterIntoBackupPasswordField(tester, '123');
      await iTapText(tester, 'OK');
      await iSeeText(tester, 'Password must be at least 4 characters');
      await noFileWasShared(tester);
    });
    testWidgets('''Cancelling the password dialog shares nothing''', (
      tester,
    ) async {
      await bddSetUp(tester);
      await iTapText(tester, 'Save');
      await iTapText(tester, 'Cancel');
      await noFileWasShared(tester);
      await iSeeText(tester, 'Your Nostr Private Key (Nsec Key)');
    });
    testWidgets(
      '''A valid password shares an encrypted backup and continues onboarding''',
      (tester) async {
        await bddSetUp(tester);
        await iTapText(tester, 'Save');
        await iEnterIntoBackupPasswordField(tester, '1234');
        await iTapText(tester, 'OK');
        await theKeyFileIsPrepared(tester);
        await aKeyBackupZipWasShared(tester);
        await iSeePage(tester, 'Select Relays');
      },
    );
  });
}
