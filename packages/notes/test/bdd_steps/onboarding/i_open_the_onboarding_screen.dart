import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_notes/unauth/presentation/onboarding/onboarding_screen.dart';
import 'package:nostr_notes/unauth/presentation/onboarding/params/onboarding_screen_params.dart';

import '../../tools/app_launcher/app_launcher.dart';

/// Usage: I open the onboarding screen
Future<void> iOpenTheOnboardingScreen(WidgetTester tester) async {
  await tester.pumpWidget(
    AppLauncher.launchApp(
      tester: tester,
      child: Builder(
        builder: (context) => Theme(
          // The InkSparkle shader asset is missing from the widget-test bundle,
          // so a tap on a button with the default splash throws.
          data: Theme.of(
            context,
          ).copyWith(splashFactory: NoSplash.splashFactory),
          child: const OnboardingScreen(
            params: OnboardingScreenParams(addAccount: false),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
