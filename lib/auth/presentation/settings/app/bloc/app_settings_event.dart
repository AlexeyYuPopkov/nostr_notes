import 'package:equatable/equatable.dart';

sealed class AppSettingsEvent extends Equatable {
  const AppSettingsEvent();

  const factory AppSettingsEvent.initial() = InitialEvent;

  @override
  List<Object?> get props => const [];
}

final class InitialEvent extends AppSettingsEvent {
  const InitialEvent();
}
