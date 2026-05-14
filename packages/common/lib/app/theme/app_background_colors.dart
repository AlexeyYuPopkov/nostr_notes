import 'package:flutter/material.dart';

/// Предустановленные цвета фона для светлой и тёмной тем.
/// Индекс 0 — цвет по умолчанию.
final class AppBackgroundColors {
  AppBackgroundColors._();

  /// Три мягких цвета фона для светлой темы.
  static const light = [
    Color(0xFFF2F2F7), // iOS system grey6 — default
    Color(0xFFFFFFFF), // white
    Color(0xFFF7F3EC), // warm paper / beige
  ];

  /// Три мягких цвета фона для тёмной темы.
  static const dark = [
    Color(0xFF000000), // pure black — default
    Color(0xFF1C1C1E), // Apple dark charcoal
    Color(0xFF18181B), // deep slate
  ];

  /// Три цвета карточек для светлой темы.
  static const lightCard = [
    Color(0xFFFFFFFF), // white (Apple Notes card) — default
    Color(0xFFFFF5E4), // warm cream
    Color(0xFFEBF3FB), // soft blue tint
  ];

  /// Три цвета карточек для тёмной темы.
  static const darkCard = [
    Color(0xFF3A3A3C), // Apple Notes dark elevated group — default
    Color(0xFF2C2C2E), // dark secondary container
    Color(0xFF1A1A2E), // deep indigo-slate
  ];
}
