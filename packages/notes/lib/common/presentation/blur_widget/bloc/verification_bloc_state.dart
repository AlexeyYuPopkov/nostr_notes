import 'package:equatable/equatable.dart';

sealed class VerificationBlocState extends Equatable {
  const VerificationBlocState();

  @override
  List<Object?> get props => [runtimeType];

  const factory VerificationBlocState.hidden() = HiddenOverlayState;

  const factory VerificationBlocState.visible() = VisibleOverlayState;
}

final class VisibleOverlayState extends VerificationBlocState {
  const VisibleOverlayState();
}

final class HiddenOverlayState extends VerificationBlocState {
  const HiddenOverlayState();
}
