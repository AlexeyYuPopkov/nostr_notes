import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nostr_notes/unauth/presentation/onboarding/onboarding_screen.dart';
import 'package:nostr_notes/unauth/presentation/onboarding/pages/onboarding_nsec_page/onboarding_nsec_sign_in.dart';
import 'package:nostr_notes/unauth/presentation/onboarding/pages/onboarding_nsec_page/onboarding_sign_up_page.dart';
import 'package:nostr_notes/unauth/presentation/onboarding/pages/onboarding_pin_page.dart';
import 'package:nostr_notes/unauth/presentation/onboarding/pages/onboarding_relays_page/onboarding_relays_page.dart';
import 'package:nostr_notes/unauth/presentation/onboarding/pages/onboarding_relays_page/widgets/relay_input_text_field.dart';
import 'package:nostr_notes/unauth/presentation/onboarding/pages/onboarding_show_nsec_page.dart';
import 'package:nostr_notes/unauth/presentation/onboarding/pages/onboarding_welcome_page.dart';

import 'test_helpers/app_launcher.dart';
import 'test_helpers/pump_helpers.dart';

/*
  bundle exec fastlane integration_test test:registration_test.dart
*/

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group(
    'User Registration Flow',
    skip: const String.fromEnvironment('RELAY_URL').isEmpty,
    () {
      testWidgets('full new user registration flow', (tester) async {
        final appLauncher = AppLauncherRobot(tester: tester);

        await appLauncher.launch();

        // Wait for rendering and initialization
        await tester.pumpAndSettle();

        // ===== STEP 1: Welcome page =====
        // Verify we are on the welcome page

        await PumpHelpers.waitFor(
          tester,
          find.byType(OnboardingScreen),
          timeout: const Duration(seconds: 10),
          reason: 'Org onboarding general info step',
        );

        expect(find.byType(OnboardingScreen), findsOneWidget);
        expect(find.byType(OnboardingWelcomePage), findsOneWidget);

        // Tap "Get Started"
        final getStartedButton = find.text('Get Started');
        expect(getStartedButton, findsOneWidget);
        await tester.tap(getStartedButton);
        await tester.pumpAndSettle();

        // ===== STEP 2: Nsec page (Sign In mode by default) =====
        // Sign In page is shown first, switch to Sign Up
        expect(find.byType(OnboardingNsecSignIn), findsOneWidget);

        // Tap "Sign Up" to switch to registration mode
        final signUpButton = find.text('Sign Up');
        expect(signUpButton, findsOneWidget);
        await tester.tap(signUpButton);
        await tester.pumpAndSettle();

        // ===== STEP 3: Sign Up page =====
        expect(find.byType(OnboardingSignUpPage), findsOneWidget);
        expect(find.text('Sign Up with Nostr'), findsOneWidget);

        // Tap "Generate a Nostr Key"
        final generateKeyButton = find.text('Generate a Nostr Key');
        expect(generateKeyButton, findsOneWidget);
        await tester.tap(generateKeyButton);
        await tester.pumpAndSettle();

        // ===== STEP 4: Show Nsec page =====
        // The generated key is displayed
        expect(find.byType(OnboardingShowNsecPage), findsOneWidget);
        expect(find.text('Your Nostr Private Key (Nsec Key)'), findsOneWidget);

        // Tap "Copy Key" — this saves the key and authenticates the user
        final copyKeyButton = find.text('Copy Key');
        expect(copyKeyButton, findsOneWidget);
        await tester.tap(copyKeyButton);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // ===== STEP 5: Relays page =====
        // After nsec authentication, the bloc navigates to the relays page
        expect(find.byType(OnboardingRelaysPage), findsOneWidget);
        expect(find.text('Select Relays'), findsOneWidget);

        // Enter a custom relay URL in the input field
        expect(find.byType(RelayInputTextField), findsOneWidget);
        final relayInput = find.byType(TextFormField);
        expect(relayInput, findsOneWidget);
        await tester.enterText(relayInput, 'ws://localhost:8008');
        await tester.pumpAndSettle();

        // Tap "Check" to verify the relay connection
        final checkButton = find.text('Check');
        expect(checkButton, findsOneWidget);
        await tester.tap(checkButton);

        // Wait for the connection check to complete (spinner → green checkmark)
        await PumpHelpers.waitFor(
          tester,
          find.text('Add'),
          timeout: const Duration(seconds: 10),
          reason: 'Relay connection check should succeed',
        );

        // Tap "Add" to add the verified relay
        final addButton = find.text('Add');
        expect(addButton, findsOneWidget);
        await tester.tap(addButton);
        await tester.pumpAndSettle();

        // Tap "Save"
        final saveButton = find.text('Save');
        expect(saveButton, findsOneWidget);
        await tester.tap(saveButton);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // ===== STEP 6: PIN page =====
        expect(find.byType(OnboardingPinPage), findsOneWidget);
        expect(find.text('Set a PIN or password'), findsOneWidget);

        // Enter PIN
        final pinField = find.byType(TextField);
        expect(pinField, findsOneWidget);
        await tester.enterText(pinField, '1234');
        await tester.pumpAndSettle();

        // Tap "Done"
        final doneButton = find.text('Done');
        expect(doneButton, findsOneWidget);
        await tester.tap(doneButton);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // ===== RESULT =====
        // After successful registration the app should navigate to the home screen
        // OnboardingScreen should no longer be visible
        expect(find.byType(OnboardingScreen), findsNothing);
      });

      testWidgets('registration with PIN disabled (no password)', (
        tester,
      ) async {
        final appLauncher = AppLauncherRobot(tester: tester);

        await appLauncher.launch();

        // Wait for rendering and initialization
        await tester.pumpAndSettle();

        // ===== STEP 1: Welcome page =====
        // Verify we are on the welcome page

        await PumpHelpers.waitFor(
          tester,
          find.byType(OnboardingScreen),
          timeout: const Duration(seconds: 10),
          reason: 'Org onboarding general info step',
        );

        // Welcome → Get Started
        await tester.tap(find.text('Get Started'));
        await tester.pumpAndSettle();

        // Sign In → Sign Up
        await tester.tap(find.text('Sign Up'));
        await tester.pumpAndSettle();

        // Sign Up → Generate Key
        await tester.tap(find.text('Generate a Nostr Key'));
        await tester.pumpAndSettle();

        // Show Nsec → Copy Key
        await tester.tap(find.text('Copy Key'));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Enter a custom relay URL in the input field
        expect(find.byType(RelayInputTextField), findsOneWidget);
        final relayInput = find.byType(TextFormField);
        expect(relayInput, findsOneWidget);
        await tester.enterText(relayInput, 'ws://localhost:8008');
        await tester.pumpAndSettle();

        // Tap "Check" to verify the relay connection
        final checkButton = find.text('Check');
        expect(checkButton, findsOneWidget);
        await tester.tap(checkButton);

        await tester.pumpAndSettle();

        // Wait for the connection check to complete (spinner → green checkmark)
        await PumpHelpers.waitFor(
          tester,
          find.text('Add'),
          timeout: const Duration(seconds: 10),
          reason: 'Relay connection check should succeed',
        );

        // Tap "Add" to add the verified relay
        final addButton = find.text('Add');
        expect(addButton, findsOneWidget);
        await tester.tap(addButton);
        await tester.pumpAndSettle();

        // Tap "Save"
        final saveButton = find.text('Save');
        expect(saveButton, findsOneWidget);
        await tester.tap(saveButton);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // PIN page — uncheck "Use pin to unlock app"
        expect(find.byType(OnboardingPinPage), findsOneWidget);

        // Find the CheckboxListTile for "Use pin to unlock app" and uncheck it
        final usePinCheckbox = find.text('Use pin to unlock app');
        expect(usePinCheckbox, findsOneWidget);
        await tester.tap(usePinCheckbox);
        await tester.pumpAndSettle();

        // Tap "Done" (PIN is not required since the checkbox is unchecked)
        await tester.tap(find.text('Done'));
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // The app should navigate to the home screen
        expect(find.byType(OnboardingScreen), findsNothing);
      });
    },
  );
}
