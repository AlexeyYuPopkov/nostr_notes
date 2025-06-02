import 'package:equatable/equatable.dart';
import 'package:nostr_notes/unauth/presentation/onboarding/pages/onboarding_step.dart';

final class OnboardingScreenData extends Equatable {
  final OnboardingStep step;
  const OnboardingScreenData._({required this.step});

  factory OnboardingScreenData.initial() {
    return const OnboardingScreenData._(
      step: OnboardingWelcome(),
    );
  }

  @override
  List<Object?> get props => [step];

  OnboardingScreenData copyWith({
    OnboardingStep? step,
  }) {
    return OnboardingScreenData._(
      step: step ?? this.step,
    );
  }
}
