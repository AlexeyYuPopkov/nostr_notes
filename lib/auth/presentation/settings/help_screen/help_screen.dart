import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:nostr_notes/app/l10n/localization.dart';
import 'package:nostr_notes/app/sizes.dart';

final class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.helpScreenTitle)),
    body: const HelpScreenContent(),
  );
}

final class HelpScreenModal extends StatelessWidget {
  const HelpScreenModal({super.key});

  @override
  Widget build(BuildContext context) {
    const leadingWidth = 80.0;
    const maxWidth = 500.0;
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      bottom: false,
      child: Align(
        alignment: .topCenter,
        child: Scaffold(
          appBar: AppBar(
            leadingWidth: leadingWidth,
            leading: CupertinoButton(
              minimumSize: .zero,
              padding: const EdgeInsets.all(Sizes.indent),
              child: Text(
                context.l10n.commonClose,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(context.l10n.helpScreenTitle),
          ),
          body: Align(
            alignment: .center,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: maxWidth),
              child: const HelpScreenContent(),
            ),
          ),
        ),
      ),
    );
  }
}

final class HelpScreenContent extends StatelessWidget {
  const HelpScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Markdown(
      padding: const EdgeInsets.only(
        left: Sizes.indent2x,
        right: Sizes.indent2x,
        top: Sizes.indent2x,
        bottom: 2.0 * Sizes.indent4x,
      ),
      data: context.l10n.helpScreenContent,
      styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
        h1: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
        h2: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        h3: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        horizontalRuleDecoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: theme.colorScheme.outline, width: 1),
          ),
        ),
        p: theme.textTheme.bodyLarge,
        blockquotePadding: const EdgeInsets.all(Sizes.indent),
        blockquoteDecoration: BoxDecoration(
          color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(Sizes.radius),
          border: Border(
            left: BorderSide(color: theme.colorScheme.error, width: 3),
          ),
        ),
      ),
    );
  }
}
