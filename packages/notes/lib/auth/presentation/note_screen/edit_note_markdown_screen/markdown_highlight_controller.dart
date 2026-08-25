import 'package:flutter/material.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/atom-one-light.dart';
import 'package:highlight/highlight.dart' show highlight;

final class MarkdownHighlightController extends TextEditingController {
  static const String language = 'markdown';
  final Map<String, TextStyle> _theme;

  MarkdownHighlightController({super.text, required Brightness brightness})
    : _theme = brightness == Brightness.dark
          ? atomOneDarkTheme
          : atomOneLightTheme;

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final text = this.text;
    if (text.isEmpty) {
      return TextSpan(text: text, style: style);
    }

    try {
      final result = highlight.parse(text, language: language);
      final spans = _convertNodes(result.nodes, style);
      return TextSpan(children: spans, style: style);
    } catch (_) {
      return TextSpan(text: text, style: style);
    }
  }

  List<TextSpan> _convertNodes(List<dynamic>? nodes, TextStyle? baseStyle) {
    final spans = <TextSpan>[];
    if (nodes == null) return spans;

    for (final node in nodes) {
      if (node is String) {
        spans.add(TextSpan(text: node, style: baseStyle));
      } else if (node.className != null) {
        final className = node.className as String;
        final nodeStyle = _theme[className];
        final mergedStyle =
            baseStyle?.merge(nodeStyle) ?? nodeStyle ?? baseStyle;

        if (node.children != null && node.children!.isNotEmpty) {
          spans.addAll(_convertNodes(node.children, mergedStyle));
        } else {
          spans.add(TextSpan(text: node.value, style: mergedStyle));
        }
      } else if (node.children != null) {
        spans.addAll(_convertNodes(node.children, baseStyle));
      } else {
        spans.add(TextSpan(text: node.value, style: baseStyle));
      }
    }

    return spans;
  }
}
