import 'package:common/app/theme/gpt_markdown_theme_data.dart';
import 'package:common/app/theme/sizes.dart';
import 'package:common/presentation/tools/link_tap_handler.dart';
import 'package:flutter/material.dart';
import 'package:gpt_markdown/custom_widgets/markdown_config.dart';
import 'package:gpt_markdown/gpt_markdown.dart';

class GptMarkdownWidget extends StatelessWidget with LinkTapHandler {
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

  @override
  Widget build(BuildContext context) {
    final mdTheme = Theme.of(context).extension<AppGptMarkdownTheme>()!;
    return GptMarkdownTheme(
      gptThemeData: mdTheme.data,
      child: GptMarkdown(
        md,
        style: const TextStyle(fontSize: TextSizes.normal),
        codeBuilder: codeBuilder,
        highlightBuilder: highlightBuilder,
        orderedListBuilder: orderedListBuilder,
        onLinkTap: (url, title) => launchUrl(context, url: url),
      ),
    );
  }
}
