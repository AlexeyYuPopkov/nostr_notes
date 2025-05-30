import 'package:equatable/equatable.dart';

sealed class OnboardingScreenEvent extends Equatable {
  const OnboardingScreenEvent();

  const factory OnboardingScreenEvent.initial() = InitialEvent;

  @override
  List<Object?> get props => const [];
}

final class InitialEvent extends OnboardingScreenEvent {
  const InitialEvent();
}
