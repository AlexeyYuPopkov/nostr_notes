import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:nostr_notes/unauth/presentation/onboarding/pages/onboarding_nsec_page/onboarding_nsec_page.dart';
import 'package:nostr_notes/unauth/presentation/onboarding/pages/onboarding_pin_page.dart';
import 'package:nostr_notes/unauth/presentation/onboarding/pages/onboarding_relays_page/onboarding_relays_page.dart';
import 'package:nostr_notes/unauth/presentation/onboarding/pages/onboarding_show_nsec_page.dart';
import 'package:nostr_notes/unauth/presentation/onboarding/pages/onboarding_welcome_page.dart';

sealed class OnboardingStep extends Equatable {
  static const pages = [
    OnboardingWelcome(),
    OnboardingNsec(),
    OnboardingShowNsec(),
    OnboardingRelays(),
    OnboardingPin(),
  ];

  const OnboardingStep();

  Widget build(BuildContext context);

  OnboardingStep? getNextStep();

  @override
  List<Object?> get props => [];
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

final class OnboardingShowNsec extends OnboardingStep {
  const OnboardingShowNsec();

  @override
  Widget build(BuildContext context) {
    return const OnboardingShowNsecPage();
  }

  @override
  OnboardingStep getNextStep() => const OnboardingPin();
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

final class OnboardingRelays extends OnboardingStep {
  const OnboardingRelays();

  @override
  Widget build(BuildContext context) {
    return const OnboardingRelaysPage();
  }

  @override
  OnboardingStep getNextStep() => const OnboardingPin();
}

final class OnboardingPin extends OnboardingStep {
  const OnboardingPin();

  @override
  Widget build(BuildContext context) {
    return const OnboardingPinPage();
  }

  @override
  OnboardingStep? getNextStep() {
    return const OnboardingWelcome();
  }
}
