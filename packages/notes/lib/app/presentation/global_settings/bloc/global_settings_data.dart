import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

final class GlobalSettingsData extends Equatable {
  final ThemeMode themeMode;
  // final OptionalBox<Locale> locale;
  const GlobalSettingsData._({
    required this.themeMode,
    // this.locale = const OptionalBox.empty(),
  });

  factory GlobalSettingsData.initial(ThemeMode? themeMode) {
    return GlobalSettingsData._(themeMode: themeMode ?? ThemeMode.system);
  }

  @override
  List<Object?> get props => [themeMode];

  GlobalSettingsData copyWith({ThemeMode? themeMode}) {
    return GlobalSettingsData._(themeMode: themeMode ?? this.themeMode);
  }
}
