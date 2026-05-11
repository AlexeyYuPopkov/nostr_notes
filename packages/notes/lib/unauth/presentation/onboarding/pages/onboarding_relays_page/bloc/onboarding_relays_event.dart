import 'package:equatable/equatable.dart';
import 'package:common/domain/model/relay_info.dart';

sealed class OnboardingRelaysEvent extends Equatable {
  const OnboardingRelaysEvent();

  const factory OnboardingRelaysEvent.initial() = InitialEvent;
  const factory OnboardingRelaysEvent.toggle(RelayInfo relay) = ToggleEvent;
  const factory OnboardingRelaysEvent.save() = SaveEvent;
  const factory OnboardingRelaysEvent.onAdd(String urlStr) = OnAddEvent;
}

final class InitialEvent extends OnboardingRelaysEvent {
  const InitialEvent();
  @override
  List<Object?> get props => [];
}

final class ToggleEvent extends OnboardingRelaysEvent {
  final RelayInfo relay;
  const ToggleEvent(this.relay);
  @override
  List<Object?> get props => [relay];
}

final class SaveEvent extends OnboardingRelaysEvent {
  const SaveEvent();
  @override
  List<Object?> get props => [];
}

final class OnAddEvent extends OnboardingRelaysEvent {
  final String urlStr;
  const OnAddEvent(this.urlStr);
  @override
  List<Object?> get props => [urlStr];
}
