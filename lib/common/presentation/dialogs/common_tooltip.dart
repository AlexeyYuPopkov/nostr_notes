import 'package:flutter/material.dart';
import 'package:nostr_notes/app/sizes.dart';

final class CommonTooltip extends StatelessWidget {
  static const showDuration = Duration(seconds: 5);
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
      richMessage: TextSpan(
        text: title,
        style: theme.textTheme.bodyMedium,
        children: [TextSpan(text: '\n$message')],
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
