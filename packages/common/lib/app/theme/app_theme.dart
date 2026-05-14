import 'package:flutter/material.dart';
import 'package:common/app/theme/sizes.dart';

import 'app_color_scheme.dart';
import 'app_text_theme.dart';
import 'gpt_markdown_theme_data.dart';
import 'shimmer_colors.dart';

final class AppTheme {
  const AppTheme();

  static ThemeData light({
    Color backgroundColor = const Color(0xFFF2F2F7),
    Color cardColor = const Color(0xFFFFFFFF),
  }) {
    return ThemeData(
      colorScheme: AppColorScheme.light.copyWith(tertiaryContainer: cardColor),
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        surfaceTintColor: backgroundColor,
        shadowColor: Colors.transparent,
        foregroundColor: AppColorScheme.light.onSurface,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: AppColorScheme.light.onSurface,
          fontSize: TextSizes.headline,
          fontWeight: FontWeight.w600,
        ),
      ),
      drawerTheme: DrawerThemeData(backgroundColor: backgroundColor),
      textTheme: AppTextTheme.createTextThemeWithColor(
        AppColorScheme.light.onSurface,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFFFFFF),
        errorStyle: TextStyle(
          color: AppColorScheme.light.error,
          fontSize: TextSizes.small,
        ),
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
      cardTheme: CardThemeData(
        color: cardColor, // Apple Notes: white card on grey background
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Sizes.radiusVariant),
        ),
        elevation: 0,
        shadowColor: Colors.transparent,
        margin: const EdgeInsets.all(Sizes.indent),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColorScheme.light.primary,
        strokeWidth: Sizes.thickness,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: backgroundColor,
        foregroundColor: AppColorScheme.light.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Sizes.radiusVariant),
        ),
      ),

      extensions: [
        ShimmerColors.fromBrightness(Brightness.light),
        AppGptMarkdownTheme.light(),
      ],
    );
  }

  static ThemeData dark({
    Color backgroundColor = const Color(0xFF000000),
    Color cardColor = const Color(0xFF3A3A3C),
  }) {
    final outline = _outlineFromCardColor(cardColor);
    return ThemeData(
      colorScheme: AppColorScheme.dark.copyWith(
        tertiaryContainer: cardColor,
        outline: outline,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        surfaceTintColor: backgroundColor,
        shadowColor: Colors.transparent,
        foregroundColor: AppColorScheme.dark.onSurface,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: AppColorScheme.dark.onSurface,
          fontSize: TextSizes.headline,
          fontWeight: FontWeight.w600,
        ),
      ),
      drawerTheme: DrawerThemeData(backgroundColor: backgroundColor),
      textTheme: AppTextTheme.createTextThemeWithColor(
        AppColorScheme.dark.onSurface,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundColor,
        errorStyle: TextStyle(
          color: AppColorScheme.dark.error,
          fontSize: TextSizes.small,
        ),
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
          foregroundColor: AppColorScheme.dark.onSurface,
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
      cardTheme: CardThemeData(
        color: cardColor, // Apple Notes dark: card on black background
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Sizes.radiusVariant),
        ),
        elevation: 0,
        shadowColor: Colors.transparent,
        margin: const EdgeInsets.all(Sizes.indent),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColorScheme.dark.secondaryContainer,
        foregroundColor: AppColorScheme.dark.primary,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Sizes.radiusVariant),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColorScheme.dark.secondaryContainer,
        contentTextStyle: TextStyle(color: AppColorScheme.dark.onSurface),
      ),

      extensions: [
        ShimmerColors.fromBrightness(Brightness.light),
        AppGptMarkdownTheme.dark(),
      ],
    );
  }

  static Color _outlineFromCardColor(Color cardColor) {
    const lightnessStep = 0.18;
    final hsl = HSLColor.fromColor(cardColor);
    final lightness = (hsl.lightness + lightnessStep).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
}
