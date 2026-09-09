import 'package:common/app/theme/sizes.dart';
import 'package:common/l10n/localization.dart';
import 'package:flutter/material.dart';

import 'note_preview_search_vm.dart';

final class NotePreviewSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final int matchCount;
  final int currentIndex;
  final bool queryNotEmpty;
  final ValueChanged<String> onChanged;
  final VoidCallback onNext;
  final VoidCallback onPrev;

  const NotePreviewSearchBar({
    super.key,
    required this.controller,
    required this.matchCount,
    required this.currentIndex,
    required this.queryNotEmpty,
    required this.onChanged,
    required this.onNext,
    required this.onPrev,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Sizes.indent,
        vertical: Sizes.indent,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => onNext(),
              decoration: InputDecoration(
                hintText: context.commonL10n.commonHintSearch,
                isDense: true,
                prefixIcon: const Icon(Icons.search, size: Sizes.iconSmall),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Sizes.radius),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: Sizes.indent,
                  horizontal: Sizes.indent,
                ),
              ),
            ),
          ),
          const SizedBox(width: Sizes.indent),
          if (queryNotEmpty)
            Text(
              matchCount > 0 ? '${currentIndex + 1} / $matchCount' : '0',
              style: theme.textTheme.bodySmall?.copyWith(
                color: matchCount > 0
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.colorScheme.error,
              ),
            ),
          IconButton(
            onPressed: matchCount > 0 ? onPrev : null,
            icon: const Icon(Icons.keyboard_arrow_up_rounded),
            iconSize: Sizes.iconMedium,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: Sizes.indent4x,
              minHeight: Sizes.indent4x,
            ),
          ),
          IconButton(
            onPressed: matchCount > 0 ? onNext : null,
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            iconSize: Sizes.iconMedium,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: Sizes.indent4x,
              minHeight: Sizes.indent4x,
            ),
          ),
        ],
      ),
    );
  }
}

final class NotePreviewSearchableText extends StatelessWidget {
  final String text;
  final List<SearchVMMatch> matches;
  final int currentMatchIndex;

  const NotePreviewSearchableText({
    super.key,
    required this.text,
    required this.matches,
    required this.currentMatchIndex,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultStyle = theme.textTheme.bodyMedium ?? const TextStyle();

    if (matches.isEmpty) {
      return Text(text, style: defaultStyle);
    }

    final spans = <InlineSpan>[];
    int cursor = 0;

    for (int i = 0; i < matches.length; i++) {
      final match = matches[i];
      if (cursor < match.start) {
        spans.add(
          TextSpan(
            text: text.substring(cursor, match.start),
            style: defaultStyle,
          ),
        );
      }
      final isCurrent = i == currentMatchIndex;
      spans.add(
        TextSpan(
          text: text.substring(match.start, match.end),
          style: defaultStyle.copyWith(
            backgroundColor: isCurrent
                ? Colors.orange.withValues(alpha: 0.7)
                : Colors.yellow.withValues(alpha: 0.5),
            color: Colors.black,
          ),
        ),
      );
      cursor = match.end;
    }

    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor), style: defaultStyle));
    }

    return SelectionArea(child: Text.rich(TextSpan(children: spans)));
  }
}
