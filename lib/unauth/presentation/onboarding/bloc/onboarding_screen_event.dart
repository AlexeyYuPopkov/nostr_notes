import 'package:equatable/equatable.dart';
import 'package:nostr_notes/common/presentation/buttons/vm/loading_button_vm.dart';
import 'package:nostr_notes/unauth/presentation/onboarding/pages/onboarding_step.dart';

sealed class OnboardingScreenEvent extends Equatable {
  const OnboardingScreenEvent();

  const factory OnboardingScreenEvent.initial() = InitialEvent;

  const factory OnboardingScreenEvent.onStep(OnboardingStep step) = OnStepEvent;
  const factory OnboardingScreenEvent.onNsec(
    String nsec,
    LoadingButtonVM vm,
  ) = OnNsecEvent;

  const factory OnboardingScreenEvent.onPin({
    required String pin,
    required LoadingButtonVM vm,
    required bool usePin,
  }) = OnPinEvent;

  @override
  List<Object?> get props => const [];
}

final class InitialEvent extends OnboardingScreenEvent {
  const InitialEvent();
}

final class OnStepEvent extends OnboardingScreenEvent {
  final OnboardingStep step;
  const OnStepEvent(this.step);
}

final class OnNsecEvent extends OnboardingScreenEvent {
  final String nsec;
  final LoadingButtonVM vm;
  const OnNsecEvent(this.nsec, this.vm);
}

final class OnPinEvent extends OnboardingScreenEvent {
  final String pin;
  final bool usePin;
  final LoadingButtonVM vm;
  const OnPinEvent({required this.pin, required this.vm, required this.usePin});
}
