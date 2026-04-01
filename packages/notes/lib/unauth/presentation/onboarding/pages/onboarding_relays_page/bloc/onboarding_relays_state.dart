import 'package:equatable/equatable.dart';

import 'onboarding_relays_data.dart';

sealed class OnboardingRelaysState extends Equatable {
  final OnboardingRelaysData data;

  const OnboardingRelaysState({required this.data});

  @override
  List<Object?> get props => [data];

  const factory OnboardingRelaysState.common({
    required OnboardingRelaysData data,
  }) = CommonState;

  const factory OnboardingRelaysState.error({
    required OnboardingRelaysData data,
    required Object e,
  }) = ErrorState;
}

final class CommonState extends OnboardingRelaysState {
  const CommonState({required super.data});
}

final class ErrorState extends OnboardingRelaysState {
  final Object e;
  const ErrorState({required super.data, required this.e});
}
