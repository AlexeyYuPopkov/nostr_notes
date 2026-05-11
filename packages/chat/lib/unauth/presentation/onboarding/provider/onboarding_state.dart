import 'package:equatable/equatable.dart';

import 'onboarding_data.dart';

sealed class OnboardingState extends Equatable {
  final OnboardingData data;
  const OnboardingState({required this.data});

  @override
  List<Object?> get props => [data];
}

final class OnboardingCommon extends OnboardingState {
  const OnboardingCommon({required super.data});
}

final class OnboardingLoading extends OnboardingState {
  const OnboardingLoading({required super.data});
}

final class OnboardingError extends OnboardingState {
  final Object error;
  const OnboardingError({required super.data, required this.error});
}

final class OnboardingDone extends OnboardingState {
  const OnboardingDone({required super.data});
}
