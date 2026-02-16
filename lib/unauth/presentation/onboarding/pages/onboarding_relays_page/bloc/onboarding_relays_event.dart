import 'package:equatable/equatable.dart';
import 'package:nostr_notes/auth/domain/model/relay_info.dart';

sealed class OnboardingRelaysEvent extends Equatable {
  const OnboardingRelaysEvent();

  const factory OnboardingRelaysEvent.initial() = InitialEvent;
  const factory OnboardingRelaysEvent.toggle(RelayInfo relay) = ToggleEvent;

  @override
  List<Object?> get props => [];
}

final class InitialEvent extends OnboardingRelaysEvent {
  const InitialEvent();
}

final class ToggleEvent extends OnboardingRelaysEvent {
  final RelayInfo relay;
  const ToggleEvent(this.relay);
}
