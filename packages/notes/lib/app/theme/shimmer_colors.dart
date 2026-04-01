import 'package:flutter/material.dart';

@immutable
class ShimmerColors extends ThemeExtension<ShimmerColors> {
  final Color baseColor;
  final Color highlightColor;
  final Color decorationColor;

  const ShimmerColors({
    required this.baseColor,
    required this.highlightColor,
    required this.decorationColor,
  });

  static ShimmerColors fromBrightness(Brightness brightness) {
    switch (brightness) {
      case Brightness.light:
        return const ShimmerColors(
          baseColor: Color(0xB3ECE6F0),
          highlightColor: Color(0xFFE8DEF8),
          decorationColor: Color(0xB3ECE6F0),
        );
      case Brightness.dark:
        return const ShimmerColors(
          baseColor: Color(0xB3ECE6F0),
          highlightColor: Color(0xFFE8DEF8),
          decorationColor: Color(0xB3ECE6F0),
        );
    }
  }

  @override
  ShimmerColors copyWith({
    Color? baseColor,
    Color? highlightColor,
    Color? decorationColor,
  }) {
    return ShimmerColors(
      baseColor: baseColor ?? this.baseColor,
      highlightColor: highlightColor ?? this.highlightColor,
      decorationColor: decorationColor ?? this.decorationColor,
    );
  }

  @override
  ShimmerColors lerp(ThemeExtension<ShimmerColors>? other, double t) {
    if (other is! ShimmerColors) return this;
    return ShimmerColors(
      baseColor: Color.lerp(baseColor, other.baseColor, t)!,
      highlightColor: Color.lerp(highlightColor, other.highlightColor, t)!,
      decorationColor: Color.lerp(decorationColor, other.decorationColor, t)!,
    );
  }
}
