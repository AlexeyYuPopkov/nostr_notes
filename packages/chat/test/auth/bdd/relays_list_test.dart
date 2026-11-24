// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import './steps/the_user_is_signed_in.dart';
import 'package:app_test_kit/bdd_steps/i_close_the_app.dart';
import './steps/i_open_the_relays_list.dart';
import 'package:app_test_kit/bdd_steps/i_see_text.dart';
import 'package:app_test_kit/bdd_steps/i_tap_semantics.dart';
import 'package:app_test_kit/bdd_steps/i_tap_text.dart';
import './steps/my_saved_relays_are.dart';

void main() {
  group('''Relays list in the settings''', () {
    Future<void> bddSetUp(WidgetTester tester) async {
      await theUserIsSignedIn(tester);
    }

    Future<void> bddTearDown(WidgetTester tester) async {
      await iCloseTheApp(tester);
    }

    testWidgets('''The relays list opens from the settings''', (tester) async {
      try {
        await bddSetUp(tester);
        await iOpenTheRelaysList(tester);
        await iSeeText(tester, 'ws://relay.test');
      } finally {
        await bddTearDown(tester);
      }
    });
    testWidgets('''A deselected relay is saved''', (tester) async {
      try {
        await bddSetUp(tester);
        await iOpenTheRelaysList(tester);
        await iTapSemantics(tester, 'RelayTile.checkbox.ws://relay.test');
        await iTapText(tester, 'Save');
        await mySavedRelaysAre(tester, '');
      } finally {
        await bddTearDown(tester);
      }
    });
  });
}
