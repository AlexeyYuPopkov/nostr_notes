import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nostr_notes/app/l10n/localization.dart';
import 'package:nostr_notes/app/sizes.dart';
import 'package:nostr_notes/common/presentation/markdown_screen.dart';

final class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.helpScreenTitle)),
    body: MarkdownScreenContent(content: context.l10n.helpScreenContent),
  );
}

final class HelpScreenModal extends StatelessWidget {
  const HelpScreenModal({super.key});

  @override
  Widget build(BuildContext context) {
    const leadingWidth = 80.0;
    const maxWidth = 500.0;
    final theme = Theme.of(context);
    final l10n = context.l10n;
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
                l10n.commonClose,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(l10n.helpScreenTitle),
          ),
          body: Align(
            alignment: .center,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: maxWidth),
              child: MarkdownScreenContent(content: l10n.helpScreenContent),
            ),
          ),
        ),
      ),
    );
  }
}
