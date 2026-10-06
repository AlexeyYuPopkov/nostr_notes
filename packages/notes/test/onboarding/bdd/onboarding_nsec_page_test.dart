// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './../../bdd_steps/common/a_fresh_install.dart';
import './../../bdd_steps/common/the_app_was_launched_before.dart';
import './../../bdd_steps/onboarding/i_open_the_onboarding_screen.dart';
import './../../bdd_steps/common/i_tap_text.dart';
import './../../bdd_steps/common/i_see_text.dart';
import './../../bdd_steps/common/input_at_first_tf.dart';
import './../../bdd_steps/common/error_at_first_tf.dart';

void main() {
  group('''Onboarding nsec page''', () {
    Future<void> bddSetUp(WidgetTester tester) async {
      await aFreshInstall(tester);
      await theAppWasLaunchedBefore(tester);
    }

    testWidgets('''User Input wrong nsec''', (tester) async {
      await bddSetUp(tester);
      await iOpenTheOnboardingScreen(tester);
      await iTapText(tester, 'Get Started');
      await iSeeText(tester, 'Enter your Nostr nsec');
      await inputAtFirstTf(tester, 'garbage');
      await iTapText(tester, 'Next');
      await errorAtFirstTf(tester, 'Invalid NSEC key');
    });
  });
}
