import 'package:equatable/equatable.dart';

sealed class VerificationBlocEvent extends Equatable {
  const VerificationBlocEvent();

  const factory VerificationBlocEvent.show() = ShowOverlayEvent;

  const factory VerificationBlocEvent.hide() = HideOverlayEvent;

  // const factory VerificationBlocEvent.checkBiometry() = CheckBiometryEvent;

  @override
  List<Object?> get props => const [];
}

final class ShowOverlayEvent extends VerificationBlocEvent {
  const ShowOverlayEvent();
}

final class HideOverlayEvent extends VerificationBlocEvent {
  const HideOverlayEvent();
}

// final class CheckBiometryEvent extends VerificationBlocEvent {
//   const CheckBiometryEvent();
// }
