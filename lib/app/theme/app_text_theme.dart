import 'package:flutter/material.dart';
import 'package:nostr_notes/app/sizes.dart';

final class AppTextTheme {
  const AppTextTheme();

  static TextTheme createTextThemeWithColor(Color color) {
    const letterSpacing = 0.12;
    return TextTheme(
      headlineLarge: TextStyle(
        color: color,
        fontSize: TextSizes.headlineLarge,
        fontWeight: FontWeight.w600,
        letterSpacing: letterSpacing,
      ),
      titleLarge: TextStyle(
        color: color,
        fontSize: TextSizes.headline,
        fontWeight: FontWeight.w600,
        letterSpacing: letterSpacing,
      ),
      titleMedium: TextStyle(
        color: color,
        fontSize: TextSizes.titleMedium,
        fontWeight: FontWeight.w600,
        letterSpacing: letterSpacing,
      ),
      bodyLarge: TextStyle(
        color: color,
        fontSize: TextSizes.normal,
        letterSpacing: letterSpacing,
      ),
      bodyMedium: TextStyle(
        color: color,
        fontSize: TextSizes.small,
        letterSpacing: letterSpacing,
      ),
    );
  }
}
