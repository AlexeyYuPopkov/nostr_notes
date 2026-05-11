import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'onboarding_welcome_page.dart';
import 'onboarding_nsec_page.dart';
import 'onboarding_show_nsec_page.dart';
import 'relays/onboarding_relays_page.dart';

sealed class OnboardingStep extends Equatable {
  static const pages = <OnboardingStep>[
    OnboardingWelcome(),
    OnboardingNsec(),
    OnboardingShowNsec(),
    OnboardingRelays(),
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
  Widget build(BuildContext context) => const OnboardingWelcomePage();

  @override
  OnboardingStep? getNextStep() => const OnboardingNsec();
}

final class OnboardingNsec extends OnboardingStep {
  const OnboardingNsec();

  @override
  Widget build(BuildContext context) => const OnboardingNsecPage();

  @override
  OnboardingStep? getNextStep() => const OnboardingRelays();
}

final class OnboardingShowNsec extends OnboardingStep {
  const OnboardingShowNsec();

  @override
  Widget build(BuildContext context) => const OnboardingShowNsecPage();

  @override
  OnboardingStep? getNextStep() => const OnboardingRelays();
}

final class OnboardingRelays extends OnboardingStep {
  const OnboardingRelays();

  @override
  Widget build(BuildContext context) => const OnboardingRelaysPage();

  @override
  OnboardingStep? getNextStep() => null;
}
