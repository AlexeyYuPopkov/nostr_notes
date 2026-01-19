import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';

final class AppGptMarkdownTheme extends ThemeExtension<AppGptMarkdownTheme> {
  final Brightness brightness;
  final GptMarkdownThemeData data;
  final Color codeBlocColor;
  final Color codeBlocBackground;
  final TextStyle rawCodeTextStyle;

  AppGptMarkdownTheme({
    required this.brightness,
    required this.data,
    required this.codeBlocColor,
    required this.codeBlocBackground,
    required this.rawCodeTextStyle,
  });

  factory AppGptMarkdownTheme.light() {
    return AppGptMarkdownTheme(
      brightness: Brightness.light,
      data: GptMarkdownThemeData(brightness: Brightness.light),
      codeBlocColor: const Color.fromARGB(255, 38, 71, 111),
      codeBlocBackground: const Color(0xFFF5F6FA),
      rawCodeTextStyle: const TextStyle(
        color: Colors.black,
        fontSize: 15.0,
        fontFamily: 'monospace',
      ),
    );
  }

  factory AppGptMarkdownTheme.dark() {
    return AppGptMarkdownTheme(
      brightness: Brightness.light,
      data: GptMarkdownThemeData(brightness: Brightness.dark),
      codeBlocColor: const Color(0xFFB8C7E0), //  Color(0xFF8FB3FF)
      codeBlocBackground: const Color(0xFF23272F), // Color(0xFF1A1D23)
      rawCodeTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 15.0,
        fontFamily: 'monospace',
      ),
    );
  }

  @override
  AppGptMarkdownTheme copyWith({
    Brightness? brightness,
    GptMarkdownThemeData? data,
    TextStyle? rawCodeTextStyle,
  }) {
    return AppGptMarkdownTheme(
      brightness: brightness ?? this.brightness,
      data: data ?? this.data,
      codeBlocColor: codeBlocColor,
      codeBlocBackground: codeBlocBackground,
      rawCodeTextStyle: rawCodeTextStyle ?? this.rawCodeTextStyle,
    );
  }

  @override
  AppGptMarkdownTheme lerp(
    ThemeExtension<AppGptMarkdownTheme>? other,
    double t,
  ) {
    if (other is! AppGptMarkdownTheme) return this;
    return AppGptMarkdownTheme(
      brightness: t < 0.5 ? brightness : other.brightness,
      data: GptMarkdownThemeData(
        brightness: t < 0.5 ? brightness : other.brightness,

        highlightColor:
            Color.lerp(data.highlightColor, other.data.highlightColor, t) ??
            data.highlightColor,
        h1: TextStyle.lerp(data.h1, other.data.h1, t) ?? data.h1,
        h2: TextStyle.lerp(data.h2, other.data.h2, t) ?? data.h2,
        h3: TextStyle.lerp(data.h3, other.data.h3, t) ?? data.h3,
        h4: TextStyle.lerp(data.h4, other.data.h4, t) ?? data.h4,
        h5: TextStyle.lerp(data.h5, other.data.h5, t) ?? data.h5,
        h6: TextStyle.lerp(data.h6, other.data.h6, t) ?? data.h6,
        hrLineThickness: Tween(
          begin: data.hrLineThickness,
          end: other.data.hrLineThickness,
        ).transform(t),
        hrLineColor:
            Color.lerp(data.hrLineColor, other.data.hrLineColor, t) ??
            data.hrLineColor,
        linkColor:
            Color.lerp(data.linkColor, other.data.linkColor, t) ??
            data.linkColor,
        linkHoverColor:
            Color.lerp(data.linkHoverColor, other.data.linkHoverColor, t) ??
            data.linkHoverColor,
      ),
      codeBlocColor:
          Color.lerp(codeBlocColor, other.codeBlocColor, t) ?? codeBlocColor,
      codeBlocBackground:
          Color.lerp(codeBlocBackground, other.codeBlocBackground, t) ??
          codeBlocBackground,
      rawCodeTextStyle:
          TextStyle.lerp(rawCodeTextStyle, other.rawCodeTextStyle, t) ??
          rawCodeTextStyle,
    );
  }
}
