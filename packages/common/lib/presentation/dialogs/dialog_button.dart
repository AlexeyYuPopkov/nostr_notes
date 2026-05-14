import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

final class DialogTextButtonUnderlined extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const DialogTextButtonUnderlined({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CupertinoButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: theme.textTheme.titleMedium?.copyWith(
          inherit: false,
          color: theme.colorScheme.primary,
          decoration: TextDecoration.underline,
          decorationColor: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

final class DialogTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const DialogTextButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CupertinoButton(
      onPressed: onPressed,

      child: Text(
        text,
        style: theme.textTheme.titleMedium?.copyWith(
          inherit: false,
          color: theme.colorScheme.primary,
          decoration: null,
          decorationColor: null,
        ),
      ),
    );
  }
}
