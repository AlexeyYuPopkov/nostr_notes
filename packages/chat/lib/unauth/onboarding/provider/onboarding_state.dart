import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'pages/onboarding_screen_step.dart';

part 'onboarding_state.g.dart';

// @riverpod
// List<OnboardingStep> onboardingSteps(Ref ref) {
//   return OnboardingStep.pages;
// }

@riverpod
final class OnboardingState extends _$OnboardingState {
  @override
  List<OnboardingStep> build() => OnboardingStep.pages;

  // void increment() => state++;
}
