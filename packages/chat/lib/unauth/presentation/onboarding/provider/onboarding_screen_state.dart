import 'package:equatable/equatable.dart';

import 'onboarding_data.dart';

sealed class OnboardingScreenState extends Equatable {
  final OnboardingData data;
  const OnboardingScreenState({required this.data});

  @override
  List<Object?> get props => [data];
}

final class OnboardingCommon extends OnboardingScreenState {
  const OnboardingCommon({required super.data});
}

final class OnboardingLoading extends OnboardingScreenState {
  const OnboardingLoading({required super.data});
}

final class OnboardingError extends OnboardingScreenState {
  final Object error;
  const OnboardingError({required super.data, required this.error});
}

final class OnboardingDone extends OnboardingScreenState {
  const OnboardingDone({required super.data});
}
