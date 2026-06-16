import 'package:common/app/theme/gpt_markdown_theme_data.dart';
import 'package:common/app/theme/sizes.dart';
import 'package:common/presentation/widgets/markdown/note_code_field.dart';
import 'package:common/presentation/widgets/markdown/on_tap_link_helper.dart';
import 'package:flutter/material.dart';
import 'package:gpt_markdown/custom_widgets/markdown_config.dart';
import 'package:gpt_markdown/gpt_markdown.dart';

class GptMarkdownWidget extends StatefulWidget {
  final String md;
  final CodeBlockBuilder? codeBuilder;
  final OrderedListBuilder? orderedListBuilder;
  final HighlightBuilder? highlightBuilder;

  const GptMarkdownWidget({
    super.key,
    required this.md,
    this.codeBuilder,
    this.orderedListBuilder,
    this.highlightBuilder,
  });

  factory GptMarkdownWidget.withCodeBuilders({
    Key? key,
    required String md,
    OrderedListBuilder? orderedListBuilder,
  }) {
    return GptMarkdownWidget(
      key: key,
      md: md,
      orderedListBuilder: orderedListBuilder,
      codeBuilder: (context, name, code, closed) =>
          NoteCodeField(name: name, codes: code),
      highlightBuilder: (context, code, closed) =>
          ShortNoteCodeField(codes: code),
    );
  }

  @override
  State<GptMarkdownWidget> createState() => _GptMarkdownWidgetState();
}

final class _GptMarkdownWidgetState extends State<GptMarkdownWidget>
    with OnTapLinkHelper {
  Offset _tapPosition = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final mdTheme = Theme.of(context).extension<AppGptMarkdownTheme>()!;
    return Listener(
      onPointerDown: (event) => _tapPosition = event.position,
      child: GptMarkdownTheme(
        gptThemeData: mdTheme.data,
        child: GptMarkdown(
          widget.md,
          style: const TextStyle(fontSize: TextSizes.normal),
          codeBuilder: widget.codeBuilder,
          highlightBuilder: widget.highlightBuilder,
          orderedListBuilder: widget.orderedListBuilder,
          onLinkTap: (url, title) =>
              onLinkTap(context, url: url.trim(), tapPosition: _tapPosition),
        ),
      ),
    );
  }
}
