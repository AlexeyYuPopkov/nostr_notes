import 'package:flutter/material.dart';
import 'package:common/app/theme/app_theme_style.dart';
import 'package:common/presentation/tools/optional_box.dart';

final class AppThemeData {
  final ThemeMode themeMode;
  final OptionalBox<String> localeCode;
  final AppThemeStyle lightThemeStyle;
  final AppThemeStyle darkThemeStyle;

  const AppThemeData({
    required this.themeMode,
    required this.localeCode,
    this.lightThemeStyle = AppThemeStyle.defaultStyle,
    this.darkThemeStyle = AppThemeStyle.defaultStyle,
  });

  AppThemeData copyWith({
    ThemeMode? themeMode,
    OptionalBox<String>? localeCode,
    AppThemeStyle? lightThemeStyle,
    AppThemeStyle? darkThemeStyle,
  }) {
    return AppThemeData(
      themeMode: themeMode ?? this.themeMode,
      localeCode: localeCode ?? this.localeCode,
      lightThemeStyle: lightThemeStyle ?? this.lightThemeStyle,
      darkThemeStyle: darkThemeStyle ?? this.darkThemeStyle,
    );
  }
}

abstract interface class AppThemeDataRepo {
  AppThemeData load();
  Future<void> save(AppThemeData data);
}
