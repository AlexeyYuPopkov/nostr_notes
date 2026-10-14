// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:notes_test_kit/bdd_steps/a_fresh_install.dart';
import 'package:notes_test_kit/bdd_steps/a_fake_clipboard.dart';
import './steps/credentials_data_screen_visible.dart';
import 'package:notes_test_kit/bdd_steps/i_see_text.dart';
import 'package:notes_test_kit/bdd_steps/i_see_semantics.dart';
import 'package:notes_test_kit/bdd_steps/i_dont_see_text.dart';
import 'package:notes_test_kit/bdd_steps/i_tap_semantics.dart';
import 'package:notes_test_kit/bdd_steps/the_clipboard_contains.dart';
import 'package:notes_test_kit/bdd_steps/i_scroll_to_semantics.dart';
import 'package:notes_test_kit/bdd_steps/fake_file_dialogs.dart';
import 'package:notes_test_kit/bdd_steps/i_enter_into_backup_password_field.dart';
import 'package:notes_test_kit/bdd_steps/i_tap_text.dart';
import 'package:notes_test_kit/bdd_steps/the_key_file_is_prepared.dart';
import 'package:notes_test_kit/bdd_steps/a_key_backup_zip_was_shared.dart';

void main() {
  group('''Credentials data screen''', () {
    Future<void> bddSetUp(WidgetTester tester) async {
      await aFreshInstall(tester);
      await aFakeClipboard(tester);
      await credentialsDataScreenVisible(tester);
    }

    testWidgets('''User Sees''', (tester) async {
      await bddSetUp(tester);
      await iSeeText(tester, 'Nsec');
      await iSeeSemantics(
        tester,
        'CredentialsDataScreen.nsec.visibilityButton',
      );
      await iDontSeeText(
        tester,
        'nsec165gu5pq9zakf8a2p9sfm97g4kaf66439crdjnl0592wd9en0588qcqrtzg',
      );
      await iTapSemantics(
        tester,
        'CredentialsDataScreen.nsec.visibilityButton',
      );
      await iSeeText(
        tester,
        'nsec165gu5pq9zakf8a2p9sfm97g4kaf66439crdjnl0592wd9en0588qcqrtzg',
      );
      await iTapSemantics(tester, 'CredentialsDataScreen.nsec.copyButton');
      await theClipboardContains(
        tester,
        'nsec165gu5pq9zakf8a2p9sfm97g4kaf66439crdjnl0592wd9en0588qcqrtzg',
      );
      await iSeeSemantics(
        tester,
        'CredentialsDataScreen.privateKey.visibilityButton',
      );
      await iDontSeeText(
        tester,
        'd511ca0405176c93f5412c13b2f915b753ad5625c0db29fdf42a9cd2e66fa1ce',
      );
      await iTapSemantics(
        tester,
        'CredentialsDataScreen.privateKey.visibilityButton',
      );
      await iSeeText(
        tester,
        'd511ca0405176c93f5412c13b2f915b753ad5625c0db29fdf42a9cd2e66fa1ce',
      );
      await iTapSemantics(
        tester,
        'CredentialsDataScreen.privateKey.copyButton',
      );
      await theClipboardContains(
        tester,
        'd511ca0405176c93f5412c13b2f915b753ad5625c0db29fdf42a9cd2e66fa1ce',
      );
      await iScrollToSemantics(tester, 'CredentialsDataScreen.npub.copyButton');
      await iSeeText(
        tester,
        'npub133uf2gtfza75lwjx00h9gq5a5krhaa8lmtcsry465aqyf2g5m78s3wlua8',
      );
      await iTapSemantics(tester, 'CredentialsDataScreen.npub.copyButton');
      await theClipboardContains(
        tester,
        'npub133uf2gtfza75lwjx00h9gq5a5krhaa8lmtcsry465aqyf2g5m78s3wlua8',
      );
      await iScrollToSemantics(
        tester,
        'CredentialsDataScreen.pubKey.copyButton',
      );
      await iSeeText(
        tester,
        '8c78952169177d4fba467bee54029da5877ef4ffdaf10192baa74044a914df8f',
      );
      await iTapSemantics(tester, 'CredentialsDataScreen.pubKey.copyButton');
      await theClipboardContains(
        tester,
        '8c78952169177d4fba467bee54029da5877ef4ffdaf10192baa74044a914df8f',
      );
      await iSeeSemantics(tester, 'CredentialsDataScreen.pin.visibilityButton');
      await iDontSeeText(tester, '270');
      await iTapSemantics(tester, 'CredentialsDataScreen.pin.visibilityButton');
      await iSeeText(tester, '270');
      await iTapSemantics(tester, 'CredentialsDataScreen.pin.copyButton');
      await theClipboardContains(tester, '270');
    });
    testWidgets('''Save the nsec to an encrypted key file''', (tester) async {
      await bddSetUp(tester);
      await fakeFileDialogs(tester);
      await iTapSemantics(tester, 'CredentialsDataScreen.nsec.saveButton');
      await iEnterIntoBackupPasswordField(tester, '1234');
      await iTapText(tester, 'OK');
      await theKeyFileIsPrepared(tester);
      await aKeyBackupZipWasShared(tester);
      await iSeeText(tester, 'Key file saved');
    });
  });
}
