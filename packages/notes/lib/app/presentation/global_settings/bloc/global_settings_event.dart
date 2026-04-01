import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

sealed class GlobalSettingsEvent extends Equatable {
  const GlobalSettingsEvent();

  const factory GlobalSettingsEvent.initial() = InitialEvent;
  const factory GlobalSettingsEvent.themeChanged({required ThemeMode mode}) =
      ThemeChangedEvent;

  @override
  List<Object?> get props => const [];
}

final class InitialEvent extends GlobalSettingsEvent {
  const InitialEvent();
}

final class ThemeChangedEvent extends GlobalSettingsEvent {
  final ThemeMode mode;
  const ThemeChangedEvent({required this.mode});

  @override
  List<Object?> get props => [mode];
}
