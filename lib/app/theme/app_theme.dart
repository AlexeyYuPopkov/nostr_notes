import 'package:flutter/material.dart';
import 'package:nostr_notes/app/sizes.dart';

import 'app_color_scheme.dart';

final class AppTheme {
  const AppTheme();

  static final light = ThemeData(
    colorScheme: AppColorScheme.light,
    useMaterial3: true,
    scaffoldBackgroundColor: AppColorScheme.light.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColorScheme.light.surface,
      foregroundColor: AppColorScheme.light.onSurface,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: AppColorScheme.light.onSurface,
        fontSize: TextSizes.headline,
        fontWeight: FontWeight.w600,
      ),
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        color: AppColorScheme.light.onSurface,
        fontSize: TextSizes.headlineLarge,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        color: AppColorScheme.light.onSurface,
        fontSize: TextSizes.headline,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: AppColorScheme.light.onSurface,
        fontSize: TextSizes.titleMedium,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: AppColorScheme.light.onSurface,
        fontSize: TextSizes.normal,
      ),
      bodyMedium: TextStyle(
        color: AppColorScheme.light.onSurface,
        fontSize: TextSizes.small,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColorScheme.light.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Sizes.radius),
        borderSide: BorderSide(color: AppColorScheme.light.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Sizes.radius),
        borderSide: BorderSide(color: AppColorScheme.light.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Sizes.radius),
        borderSide: BorderSide(color: AppColorScheme.light.primary),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColorScheme.light.primary,
        foregroundColor: AppColorScheme.light.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Sizes.radius),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: Sizes.indentVariant4x,
          vertical: Sizes.paddingVariant2x,
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    cardTheme: CardTheme(
      color: AppColorScheme.light.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Sizes.radiusVariant),
      ),
      elevation: 2,
      margin: const EdgeInsets.all(Sizes.indent),
    ),
  );

  static final dark = ThemeData(
    colorScheme: AppColorScheme.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: AppColorScheme.dark.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColorScheme.dark.surface,
      foregroundColor: AppColorScheme.dark.onSurface,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: AppColorScheme.dark.onSurface,
        fontSize: TextSizes.headline,
        fontWeight: FontWeight.w600,
      ),
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        color: AppColorScheme.dark.onSurface,
        fontSize: TextSizes.headlineLarge,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        color: AppColorScheme.dark.onSurface,
        fontSize: TextSizes.headline,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: AppColorScheme.dark.onSurface,
        fontSize: TextSizes.titleMedium,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: AppColorScheme.dark.onSurface,
        fontSize: TextSizes.normal,
      ),
      bodyMedium: TextStyle(
        color: AppColorScheme.dark.onSurface,
        fontSize: TextSizes.small,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColorScheme.dark.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Sizes.radius),
        borderSide: BorderSide(color: AppColorScheme.dark.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Sizes.radius),
        borderSide: BorderSide(color: AppColorScheme.dark.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Sizes.radius),
        borderSide: BorderSide(color: AppColorScheme.dark.primary),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColorScheme.dark.primary,
        foregroundColor: AppColorScheme.dark.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Sizes.radius),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: Sizes.indentVariant4x,
          vertical: Sizes.paddingVariant2x,
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    cardTheme: CardTheme(
      color: AppColorScheme.dark.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Sizes.radiusVariant),
      ),
      elevation: 2,
      margin: const EdgeInsets.all(Sizes.indent),
    ),
  );
}
