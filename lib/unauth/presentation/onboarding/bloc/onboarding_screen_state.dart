import 'package:equatable/equatable.dart';

import 'onboarding_screen_data.dart';

sealed class OnboardingScreenState extends Equatable {
  final OnboardingScreenData data;

  const OnboardingScreenState({required this.data});

  @override
  List<Object?> get props => [data];

  const factory OnboardingScreenState.common({
    required OnboardingScreenData data,
  }) = CommonState;

  const factory OnboardingScreenState.loading({
    required OnboardingScreenData data,
  }) = LoadingState;

  const factory OnboardingScreenState.error({
    required OnboardingScreenData data,
    required Object e,
  }) = ErrorState;

  const factory OnboardingScreenState.didUnlock({
    required OnboardingScreenData data,
  }) = DidUnlockState;
}

final class CommonState extends OnboardingScreenState {
  const CommonState({required super.data});
}

final class LoadingState extends OnboardingScreenState {
  const LoadingState({required super.data});
}

final class DidUnlockState extends OnboardingScreenState {
  const DidUnlockState({required super.data});
}

final class ErrorState extends OnboardingScreenState {
  final Object e;
  const ErrorState({
    required super.data,
    required this.e,
  });
}
