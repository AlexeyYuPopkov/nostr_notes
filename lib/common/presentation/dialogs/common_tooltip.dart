import 'package:flutter/material.dart';
import 'package:nostr_notes/app/sizes.dart';

final class CommonTooltip extends StatelessWidget {
  static const showDuration = Duration(seconds: 10);
  final String title;
  final String message;
  final Widget? child;

  const CommonTooltip({
    super.key,
    required this.title,
    required this.message,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      padding: const EdgeInsets.all(Sizes.indent),
      margin: const EdgeInsets.symmetric(horizontal: Sizes.indent4x),
      constraints: const BoxConstraints(maxWidth: 400),
      richMessage: TextSpan(
        text: title,
        style: theme.textTheme.titleSmall?.copyWith(height: 2.0),
        children: [
          TextSpan(text: '\n$message', style: theme.textTheme.bodyMedium),
        ],
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.all(Radius.circular(Sizes.radius)),
        border: Border.all(
          color: theme.colorScheme.outline,
          width: Sizes.thickness,
        ),
      ),
      showDuration: showDuration,
      textStyle: theme.textTheme.bodyMedium,
      child: child,
    );
  }
}
