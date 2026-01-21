import 'package:equatable/equatable.dart';
import 'package:nostr_notes/unauth/presentation/onboarding/pages/onboarding_step.dart';

final class OnboardingScreenData extends Equatable {
  final OnboardingStep step;
  final String? generatedNsec;

  const OnboardingScreenData._({required this.step, this.generatedNsec});

  factory OnboardingScreenData.initial() {
    return const OnboardingScreenData._(step: OnboardingWelcome());
  }

  @override
  List<Object?> get props => [step, generatedNsec];

  OnboardingScreenData copyWith({OnboardingStep? step, String? generatedNsec}) {
    return OnboardingScreenData._(
      step: step ?? this.step,
      generatedNsec: generatedNsec ?? this.generatedNsec,
    );
  }
}
