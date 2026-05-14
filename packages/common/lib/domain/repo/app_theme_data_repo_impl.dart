import 'package:flutter/material.dart';

final class AppThemeData {
  final ThemeMode themeMode;
  final int lightBgIndex;
  final int darkBgIndex;
  final int lightCardIndex;
  final int darkCardIndex;

  const AppThemeData({
    required this.themeMode,
    required this.lightBgIndex,
    required this.darkBgIndex,
    this.lightCardIndex = 0,
    this.darkCardIndex = 0,
  });

  AppThemeData copyWith({
    ThemeMode? themeMode,
    int? lightBgIndex,
    int? darkBgIndex,
    int? lightCardIndex,
    int? darkCardIndex,
  }) {
    return AppThemeData(
      themeMode: themeMode ?? this.themeMode,
      lightBgIndex: lightBgIndex ?? this.lightBgIndex,
      darkBgIndex: darkBgIndex ?? this.darkBgIndex,
      lightCardIndex: lightCardIndex ?? this.lightCardIndex,
      darkCardIndex: darkCardIndex ?? this.darkCardIndex,
    );
  }
}

abstract interface class AppThemeDataRepo {
  AppThemeData load();
  Future<void> save(AppThemeData data);
}
