import 'package:flutter/material.dart';

final class AppColorScheme {
  const AppColorScheme();

  static const light = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF0066CC), // Акцент (синий)
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFD6E4FF),
    onPrimaryContainer: Color(0xFF003366),
    secondary: Color(0xFF4A4A4A), // Тёмно-серый для вторичного текста
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFF2F2F7),
    onSecondaryContainer: Color(0xFF1C1C1E),
    surface: Color(0xFFFFFFFF), // Для карточек, полей ввода
    onSurface: Color(0xFF1C1C1E),
    error: Color(0xFFB00020),
    onError: Colors.white,
    outline: Color(0xFFCED4DA), // Границы
  );

  static const dark = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF3399FF), // Акцентный синий
    onPrimary: Colors.black,
    primaryContainer: Color(0xFF003366),
    onPrimaryContainer: Color(0xFFD6E4FF),
    secondary: Color(0xFFCCCCCC), // Светло-серый текст
    onSecondary: Colors.black,
    secondaryContainer: Color(0xFF2C2C2E),
    onSecondaryContainer: Color(0xFFE5E5EA),
    surface: Color(0xFF1C1C1E), // Карточки, поля
    onSurface: Color(0xFFF2F2F2),
    error: Color(0xFFFF6B6B),
    onError: Colors.black,
    outline: Color(0xFF3A3A3C), // Линии, бордеры
  );
}
