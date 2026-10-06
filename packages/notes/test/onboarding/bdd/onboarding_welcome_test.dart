// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './../../bdd_steps/common/a_fresh_install.dart';
import './../../bdd_steps/onboarding/i_open_the_onboarding_screen.dart';
import './../../bdd_steps/common/i_see_text.dart';
import './../../bdd_steps/common/i_tap_text.dart';
import './../../bdd_steps/common/i_see_page.dart';
import '../../bdd_steps/common/the_app_was_launched_before.dart';

void main() {
  group('''Onboarding welcome page''', () {
    Future<void> bddSetUp(WidgetTester tester) async {
      await aFreshInstall(tester);
    }

    testWidgets('''A new user sees the welcome page''', (tester) async {
      await bddSetUp(tester);
      await iOpenTheOnboardingScreen(tester);
      await iSeeText(tester, 'Get Started');
      await iSeeText(tester, 'Help');
    });
    testWidgets('''Get Started offers sign up on the first launch''', (
      tester,
    ) async {
      await bddSetUp(tester);
      await iOpenTheOnboardingScreen(tester);
      await iTapText(tester, 'Get Started');
      await iSeePage(tester, 'Sign Up with Nostr');
    });
    testWidgets(
      '''Get Started offers sign in once the app was launched before''',
      (tester) async {
        await bddSetUp(tester);
        await theAppWasLaunchedBefore(tester);
        await iOpenTheOnboardingScreen(tester);
        await iTapText(tester, 'Get Started');
        await iSeePage(tester, 'Enter your Nostr nsec');
      },
    );
  });
}
