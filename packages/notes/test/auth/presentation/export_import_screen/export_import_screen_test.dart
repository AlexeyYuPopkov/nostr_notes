// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:notes_test_kit/bdd_steps/a_fresh_install.dart';
import './steps/export_import_screen_visible.dart';
import 'package:notes_test_kit/bdd_steps/fake_file_dialogs.dart';
import 'package:notes_test_kit/bdd_steps/i_see_text.dart';
import 'package:notes_test_kit/bdd_steps/i_tap_semantics.dart';
import 'package:notes_test_kit/bdd_steps/i_enter_into_backup_password_field.dart';
import 'package:notes_test_kit/bdd_steps/i_tap_text.dart';
import 'package:notes_test_kit/bdd_steps/the_key_file_is_prepared.dart';
import 'package:notes_test_kit/bdd_steps/a_key_backup_zip_was_shared.dart';

void main() {
  group('''Export import screen''', () {
    Future<void> bddSetUp(WidgetTester tester) async {
      await aFreshInstall(tester);
      await exportImportScreenVisible(tester);
    }

    testWidgets('''Export the current account's key to an encrypted file''', (
      tester,
    ) async {
      await bddSetUp(tester);
      await fakeFileDialogs(tester);
      await iSeeText(tester, 'Keys');
      await iTapSemantics(tester, 'ExportImportScreen.exportKeyItem');
      await iEnterIntoBackupPasswordField(tester, '1234');
      await iTapText(tester, 'OK');
      await theKeyFileIsPrepared(tester);
      await aKeyBackupZipWasShared(tester);
      await iSeeText(tester, 'Key file saved');
    });
  });
}
