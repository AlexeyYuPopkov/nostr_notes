import 'package:flutter/material.dart';

final class AppColorScheme {
  const AppColorScheme();

  static const light = ColorScheme(
    brightness: Brightness.light,

    primary: Color(0xFF7C43C7), // мягкий фиолетовый
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFECE2FA), // светлый фон в стиле фиолетового
    onPrimaryContainer: Color(0xFF3D1D74),

    secondary: Color(0xFFB49C73), // тёплый беж
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFF5EEE3),
    onSecondaryContainer: Color(0xFF5B4A2F),

    surface: Color(0xFFFDFCF9), // тёплый почти-белый фон
    onSurface: Color(0xFF2E2E2E),

    error: Color(0xFFB00020),
    onError: Colors.white,

    outline: Color(0xFFE0E0E0),
  );

  static const dark = ColorScheme(
    brightness: Brightness.dark,

    primary: Color(0xFFB491E5), // осветлённый фиолетовый для тёмной темы
    onPrimary: Colors.black,
    primaryContainer: Color(0xFF3D2663),
    onPrimaryContainer: Color(0xFFE5D4FF),

    secondary: Color(0xFFD4C3A4),
    onSecondary: Colors.black,
    secondaryContainer: Color(0xFF3E372A),
    onSecondaryContainer: Color(0xFFF5EBDD),

    surface: Color(0xFF1A1A1A),
    onSurface: Color(0xFFE6E6E6),

    error: Color(0xFFFF6B6B),
    onError: Colors.black,

    outline: Color(0xFF3A3A3A),
  );
}
