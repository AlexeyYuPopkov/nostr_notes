// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './../../bdd_steps/common/a_fresh_install.dart';
import './../../bdd_steps/keys_backup/fake_file_dialogs.dart';
import './../../bdd_steps/onboarding/i_open_the_onboarding_screen.dart';
import './../../bdd_steps/common/i_tap_text.dart';
import './../../bdd_steps/common/i_see_text.dart';
import './../../bdd_steps/keys_backup/i_enter_into_backup_password_field.dart';
import './../../bdd_steps/keys_backup/no_file_was_shared.dart';
import './../../bdd_steps/common/i_see_page.dart';
import './../../bdd_steps/keys_backup/a_key_backup_zip_was_shared.dart';

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
      await iSeeText(tester, 'Save to File');
    }, tags: ['wip']);
    testWidgets('''The backup password must be at least 4 characters''', (
      tester,
    ) async {
      await bddSetUp(tester);
      await iTapText(tester, 'Save to File');
      await iEnterIntoBackupPasswordField(tester, '123');
      await iTapText(tester, 'OK');
      await iSeeText(tester, 'Password must be at least 4 characters');
      await noFileWasShared(tester);
    }, tags: ['wip']);
    testWidgets('''Cancelling the password dialog shares nothing''', (
      tester,
    ) async {
      await bddSetUp(tester);
      await iTapText(tester, 'Save to File');
      await iTapText(tester, 'Cancel');
      await noFileWasShared(tester);
      await iSeePage(tester, 'Your Nostr Private Key (Nsec Key)');
    }, tags: ['wip']);
    testWidgets(
      '''A valid password shares an encrypted backup and continues onboarding''',
      (tester) async {
        await bddSetUp(tester);
        await iTapText(tester, 'Save to File');
        await iEnterIntoBackupPasswordField(tester, '1234');
        await iTapText(tester, 'OK');
        await aKeyBackupZipWasShared(tester);
        await iSeePage(tester, 'Select Relays');
      },
      tags: ['wip'],
    );
  });
}
