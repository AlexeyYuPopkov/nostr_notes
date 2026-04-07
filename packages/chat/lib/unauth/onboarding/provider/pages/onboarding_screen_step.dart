import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'onboarding_welcome_page.dart';

sealed class OnboardingStep extends Equatable {
  static const pages = <OnboardingStep>[
    OnboardingWelcome(),
    // OnboardingNsec(),
    // OnboardingShowNsec(),
    // OnboardingRelays(),
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

  @override
  OnboardingStep? getNextStep() => null;
}
