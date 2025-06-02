import 'package:flutter/material.dart';
import 'package:nostr_notes/unauth/presentation/onboarding/pages/onboarding_nsec_page.dart';
import 'package:nostr_notes/unauth/presentation/onboarding/pages/onboarding_pin_page.dart';
import 'package:nostr_notes/unauth/presentation/onboarding/pages/onboarding_welcome_page.dart';

sealed class OnboardingStep {
  static const pages = [
    OnboardingWelcome(),
    OnboardingNsec(),
    OnboardingPin(),
  ];

  const OnboardingStep();

  Widget build(BuildContext context);

  OnboardingStep? getNextStep();
}

final class OnboardingWelcome extends OnboardingStep {
  const OnboardingWelcome();

  @override
  Widget build(BuildContext context) {
    return const OnboardingWelcomePage();
  }

  OnboardingStep? get next {
    return const OnboardingNsec();
  }

  @override
  OnboardingStep getNextStep() => const OnboardingNsec();
}

final class OnboardingNsec extends OnboardingStep {
  const OnboardingNsec();

  @override
  Widget build(BuildContext context) {
    return const OnboardingNsecPage();
  }

  @override
  OnboardingStep? getNextStep() => const OnboardingPin();
}

final class OnboardingPin extends OnboardingStep {
  const OnboardingPin();

  @override
  Widget build(BuildContext context) {
    return const OnboardingPinPage();
  }

  @override
  OnboardingStep? getNextStep() => null;
}
