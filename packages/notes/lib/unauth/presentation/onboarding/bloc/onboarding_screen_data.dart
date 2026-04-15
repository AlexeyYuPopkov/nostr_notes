import 'package:equatable/equatable.dart';
import 'package:nostr_notes/common/domain/model/pin_keyboard_type.dart';
import 'package:nostr_notes/unauth/presentation/onboarding/pages/onboarding_step.dart';

final class OnboardingScreenData extends Equatable {
  final OnboardingStep step;
  final PinKeyboardType pinKeyboardType;
  final String? generatedNsec;
  final bool isUsePin;

  const OnboardingScreenData._({
    required this.step,
    required this.pinKeyboardType,
    required this.generatedNsec,
    required this.isUsePin,
  });

  factory OnboardingScreenData.initial() {
    return const OnboardingScreenData._(
      step: OnboardingWelcome(),
      pinKeyboardType: PinKeyboardType.text,
      generatedNsec: null,
      isUsePin: true,
    );
  }

  @override
  List<Object?> get props => [step, generatedNsec, pinKeyboardType, isUsePin];

  OnboardingScreenData copyWith({
    OnboardingStep? step,
    PinKeyboardType? pinKeyboardType,
    String? generatedNsec,
    bool? isUsePin,
  }) {
    return OnboardingScreenData._(
      step: step ?? this.step,
      pinKeyboardType: pinKeyboardType ?? this.pinKeyboardType,
      generatedNsec: generatedNsec ?? this.generatedNsec,
      isUsePin: isUsePin ?? this.isUsePin,
    );
  }
}
