import 'package:common/app/theme/sizes.dart';
import 'package:common/presentation/widgets/markdown/gpt_markdown_widget.dart';
import 'package:flutter/material.dart';

import 'package:common/presentation/tools/link_tap_handler.dart';
import 'package:gpt_markdown/custom_widgets/unordered_ordered_list.dart';

final class MarkdownScreen extends StatelessWidget {
  final String title;
  final String content;
  const MarkdownScreen({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: MarkdownScreenContent(content: content),
  );
}

final class MarkdownScreenContent extends StatelessWidget with LinkTapHandler {
  final String content;
  const MarkdownScreenContent({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            left: Sizes.indent2x,
            right: Sizes.indent2x,
            top: Sizes.indent2x,
            bottom: 2.0 * Sizes.indent4x,
          ),
          child: GptMarkdownWidget(
            md: content,
            orderedListBuilder: (context, no, child, config) => OrderedListView(
              no: '$no.',
              textDirection: config.textDirection,
              style: config.style?.copyWith(fontWeight: FontWeight.w600),
              child: child,
            ),
          ),
        ),
      ),
    );

    // return SelectionArea(
    //   child: Markdown(
    //     padding: const EdgeInsets.only(
    //       left: Sizes.indent2x,
    //       right: Sizes.indent2x,
    //       top: Sizes.indent2x,
    //       bottom: 2.0 * Sizes.indent4x,
    //     ),
    //     data: content,
    //     styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
    //       h1: theme.textTheme.headlineMedium?.copyWith(
    //         fontWeight: FontWeight.bold,
    //       ),
    //       h2: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    //       h3: theme.textTheme.titleMedium?.copyWith(
    //         fontWeight: FontWeight.bold,
    //       ),
    //       horizontalRuleDecoration: BoxDecoration(
    //         border: Border(
    //           top: BorderSide(color: theme.colorScheme.outline, width: 1),
    //         ),
    //       ),
    //       p: theme.textTheme.bodyLarge,
    //       blockquotePadding: const EdgeInsets.all(Sizes.indent),
    //       blockquoteDecoration: BoxDecoration(
    //         color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
    //         borderRadius: BorderRadius.circular(Sizes.radius),
    //         border: Border(
    //           left: BorderSide(color: theme.colorScheme.error, width: 3),
    //         ),
    //       ),
    //     ),
    //     onTapLink: (text, href, title) => launchUrl(context, url: href),
    //   ),
    // );
  }
}

// final class _Option extends StatelessWidget {
//   final String md;
//   const _Option({required this.md});

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return GptMarkdown(style: theme.textTheme.bodyLarge, md);
//   }
// }
