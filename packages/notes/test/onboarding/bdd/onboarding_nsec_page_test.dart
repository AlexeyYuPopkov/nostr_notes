// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:notes_test_kit/bdd_steps/a_fresh_install.dart';
import 'package:notes_test_kit/bdd_steps/the_app_was_launched_before.dart';
import './steps/i_open_the_onboarding_screen.dart';
import 'package:notes_test_kit/bdd_steps/i_tap_text.dart';
import 'package:notes_test_kit/bdd_steps/i_see_text.dart';
import 'package:notes_test_kit/bdd_steps/input_at_first_tf.dart';
import 'package:notes_test_kit/bdd_steps/error_at_first_tf.dart';

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
