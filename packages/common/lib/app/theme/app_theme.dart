import 'package:flutter/material.dart';
import 'package:common/app/theme/sizes.dart';

import 'app_color_scheme.dart';
import 'app_text_theme.dart';
import 'app_theme_style.dart';
import 'gpt_markdown_theme_data.dart';
import 'shimmer_colors.dart';
import 'success_colors.dart';

final class AppTheme {
  const AppTheme();

  static ThemeData light({AppThemeStyle style = AppThemeStyle.defaultStyle}) {
    final palette = style.paletteFor(Brightness.light);
    return ThemeData(
      // primary/surface/tertiaryContainer/outline below always come from
      // [palette] — the values baked into AppColorScheme.light for those
      // fields are just a fallback shape, never what actually renders.
      colorScheme: AppColorScheme.light.copyWith(
        primary: palette.primary,
        onPrimary: palette.onPrimary,
        primaryContainer: palette.primaryContainer,
        onPrimaryContainer: palette.onPrimaryContainer,
        surface: palette.background,
        tertiaryContainer: palette.card,
        outline: palette.outline,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: palette.background,
      appBarTheme: AppBarTheme(
        backgroundColor: palette.background,
        surfaceTintColor: palette.background,
        shadowColor: Colors.transparent,
        foregroundColor: AppColorScheme.light.onSurface,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: AppColorScheme.light.onSurface,
          fontSize: TextSizes.headline,
          fontWeight: FontWeight.w600,
        ),
      ),
      drawerTheme: DrawerThemeData(backgroundColor: palette.background),
      textTheme: AppTextTheme.createTextThemeWithColor(
        AppColorScheme.light.onSurface,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.card,
        errorStyle: TextStyle(
          color: AppColorScheme.light.error,
          fontSize: TextSizes.small,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Sizes.radius),
          borderSide: BorderSide(color: palette.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Sizes.radius),
          borderSide: BorderSide(color: palette.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Sizes.radius),
          borderSide: BorderSide(color: palette.primary),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: palette.onPrimary,
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
        color: palette.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Sizes.radiusVariant),
        ),
        elevation: 0,
        shadowColor: Colors.transparent,
        margin: const EdgeInsets.all(Sizes.indent),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: palette.primary,
        strokeWidth: Sizes.thickness,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: palette.background,
        foregroundColor: palette.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Sizes.radiusVariant),
        ),
      ),

      extensions: [
        ShimmerColors.fromBrightness(Brightness.light),
        AppGptMarkdownTheme.light(),
        SuccessColors.light,
      ],
    );
  }

  static ThemeData dark({AppThemeStyle style = AppThemeStyle.defaultStyle}) {
    final palette = style.paletteFor(Brightness.dark);
    return ThemeData(
      colorScheme: AppColorScheme.dark.copyWith(
        primary: palette.primary,
        onPrimary: palette.onPrimary,
        primaryContainer: palette.primaryContainer,
        onPrimaryContainer: palette.onPrimaryContainer,
        surface: palette.background,
        tertiaryContainer: palette.card,
        outline: palette.outline,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: palette.background,
      appBarTheme: AppBarTheme(
        backgroundColor: palette.background,
        surfaceTintColor: palette.background,
        shadowColor: Colors.transparent,
        foregroundColor: AppColorScheme.dark.onSurface,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: AppColorScheme.dark.onSurface,
          fontSize: TextSizes.headline,
          fontWeight: FontWeight.w600,
        ),
      ),
      drawerTheme: DrawerThemeData(backgroundColor: palette.background),
      textTheme: AppTextTheme.createTextThemeWithColor(
        AppColorScheme.dark.onSurface,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.background,
        errorStyle: TextStyle(
          color: AppColorScheme.dark.error,
          fontSize: TextSizes.small,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Sizes.radius),
          borderSide: BorderSide(color: palette.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Sizes.radius),
          borderSide: BorderSide(color: palette.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Sizes.radius),
          borderSide: BorderSide(color: palette.primary),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: palette.onPrimary,
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
        color: palette.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Sizes.radiusVariant),
        ),
        elevation: 0,
        shadowColor: Colors.transparent,
        margin: const EdgeInsets.all(Sizes.indent),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColorScheme.dark.secondaryContainer,
        foregroundColor: palette.primary,
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
        SuccessColors.dark,
      ],
    );
  }
}
