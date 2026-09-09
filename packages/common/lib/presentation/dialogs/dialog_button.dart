import 'package:common/app/theme/sizes.dart';
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
        style: theme.textTheme.titleSmall?.copyWith(
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
        style: theme.textTheme.titleSmall?.copyWith(
          inherit: false,
          color: theme.colorScheme.primary,
          decoration: null,
          decorationColor: null,
        ),
      ),
    );
  }
}

final class DialogTextButtonFilled extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const DialogTextButtonFilled({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CupertinoButton(
      color: theme.colorScheme.primary,
      minimumSize: Size.zero,
      borderRadius: BorderRadius.circular(Sizes.radiusVariant),
      onPressed: onPressed,
      child: Text(
        text,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.onPrimary,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
