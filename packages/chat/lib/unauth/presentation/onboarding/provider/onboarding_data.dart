import 'package:equatable/equatable.dart';

import 'pages/onboarding_screen_step.dart';

final class OnboardingData extends Equatable {
  final OnboardingStep step;
  final String? generatedNsec;

  const OnboardingData._({required this.step, this.generatedNsec});

  factory OnboardingData.initial() {
    return const OnboardingData._(step: OnboardingWelcome());
  }

  OnboardingData copyWith({OnboardingStep? step, String? generatedNsec}) {
    return OnboardingData._(
      step: step ?? this.step,
      generatedNsec: generatedNsec ?? this.generatedNsec,
    );
  }

  @override
  List<Object?> get props => [step, generatedNsec];
}
