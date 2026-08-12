import 'package:flutter/material.dart';
import 'package:common/l10n/localization.dart';

/// A full, independently-selectable theme style — chosen separately for
/// light and dark brightness (see `GlobalSettingsVm.lightThemeStyle` /
/// `.darkThemeStyle`). Styles differ only in [AppThemePalette] (primary,
/// background, card, outline) — shape, spacing and typography stay shared
/// across all of them, see [AppTheme].
enum AppThemeStyle {
  defaultStyle,
  appleNotes,
  claude;

  String getLocalizedName(BuildContext context) {
    final l10n = context.commonL10n;
    return switch (this) {
      AppThemeStyle.defaultStyle => l10n.themeScreenStyleDefault,
      AppThemeStyle.appleNotes => l10n.themeScreenStyleAppleNotes,
      AppThemeStyle.claude => l10n.themeScreenStyleClaude,
    };
  }
}

/// The set of colors that actually differ between [AppThemeStyle]s.
/// Everything else in the resulting `ThemeData` (radii, elevation, text
/// theme, secondary/error colors) is shared — see `AppTheme.light`/`.dark`.
final class AppThemePalette {
  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color background;
  final Color card;
  final Color outline;

  const AppThemePalette({
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.background,
    required this.card,
    required this.outline,
  });
}

extension AppThemeStylePalette on AppThemeStyle {
  AppThemePalette paletteFor(Brightness brightness) {
    return switch ((this, brightness)) {
      (AppThemeStyle.defaultStyle, Brightness.light) => _defaultLight,
      (AppThemeStyle.defaultStyle, Brightness.dark) => _defaultDark,
      (AppThemeStyle.appleNotes, Brightness.light) => _appleNotesLight,
      (AppThemeStyle.appleNotes, Brightness.dark) => _appleNotesDark,
      (AppThemeStyle.claude, Brightness.light) => _claudeLight,
      (AppThemeStyle.claude, Brightness.dark) => _claudeDark,
    };
  }
}

// Default — the app's own look. Primary purple is the one deliberate break
// from Apple Notes style below; background/card are nudged just enough to
// feel coordinated with that purple, without changing the overall shape.
const _defaultLight = AppThemePalette(
  primary: Color(0xFF7C43C7),
  onPrimary: Colors.white,
  primaryContainer: Color(0xFFECE2FA),
  onPrimaryContainer: Color(0xFF3D1D74),
  background: Color(0xFFF4F1FA), // faint violet tint, was flat iOS grey6
  card: Colors.white,
  outline: Color(0xFFE4DEF0),
);

const _defaultDark = AppThemePalette(
  primary: Color(0xFFB491E5),
  onPrimary: Color(0xFF2B1B3D),
  primaryContainer: Color(0xFF3D2663),
  onPrimaryContainer: Color(0xFFE5D4FF),
  background: Colors.black, // kept pure black on purpose
  card: Color(0xFF2A2233), // warm plum-tinted card, was neutral grey
  outline: Color(0xFF3D3646),
);

// Apple Notes — same shape as Default, accent moved to iOS Notes' system
// yellow and background/card reverted to a neutral (non-purple) grey.
const _appleNotesLight = AppThemePalette(
  primary: Color(0xFFE0A500), // darkened from FFC300 — read too washed out
  onPrimary: Color(0xFF3D2E00),
  primaryContainer: Color(0xFFFFF3CC),
  onPrimaryContainer: Color(0xFF4D3800),
  background: Color(0xFFF2F2F2),
  card: Colors.white,
  outline: Color(0xFFE1E1E1),
);

const _appleNotesDark = AppThemePalette(
  primary: Color(0xFFFFD60A), // iOS systemYellow, dark variant
  onPrimary: Color(0xFF2B2000),
  primaryContainer: Color(0xFF4D3D00),
  onPrimaryContainer: Color(0xFFFFE9A8),
  background: Colors.black,
  card: Color(0xFF1C1C1E),
  outline: Color(0xFF38383A),
);

// Claude — warm oat background and terracotta accent, matching the Claude
// app; cards sit a shade lighter than the page instead of pure white.
const _claudeLight = AppThemePalette(
  primary: Color(0xFFD97757),
  onPrimary: Colors.white,
  primaryContainer: Color(0xFFF7E4DA),
  onPrimaryContainer: Color(0xFF6B2E17),
  background: Color(0xFFF5F3EC),
  card: Color.fromARGB(255, 255, 254, 249), // Color(0xFFFAF8F2),
  outline: Color(0xFFE8E3D6),
);

const _claudeDark = AppThemePalette(
  primary: Color(0xFFE0815E),
  onPrimary: Color(0xFF2B140A),
  primaryContainer: Color(0xFF5A3322),
  onPrimaryContainer: Color(0xFFFFD9C2),
  background: Color(0xFF262624), // warm charcoal, not pure black
  card: Color.fromARGB(255, 49, 48, 44), // Color(0xFF2F2E2A),
  outline: Color(0xFF3D3B36),
);
