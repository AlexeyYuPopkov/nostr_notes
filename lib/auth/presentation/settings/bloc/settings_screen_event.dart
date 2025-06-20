import 'package:equatable/equatable.dart';

sealed class SettingsScreenEvent extends Equatable {
  const SettingsScreenEvent();

  const factory SettingsScreenEvent.exit() = ExitEvent;
  const factory SettingsScreenEvent.logout() = LogoutEvent;

  @override
  List<Object?> get props => const [];
}

final class ExitEvent extends SettingsScreenEvent {
  const ExitEvent();
}

final class LogoutEvent extends SettingsScreenEvent {
  const LogoutEvent();
}
