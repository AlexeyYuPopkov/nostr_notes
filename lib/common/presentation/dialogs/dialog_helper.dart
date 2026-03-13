import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nostr_notes/app/l10n/localization.dart';
import 'package:nostr_notes/app/sizes.dart';
import 'package:nostr_notes/common/domain/error/app_error.dart';

mixin DialogHelper {
  Future<dynamic> showError(
    BuildContext context, {
    required Object error,
  }) async {
    final message = error is AppError
        ? error.message.isNotEmpty
              ? error.message
              : context.l10n.commonUndefinedError
        : context.l10n.commonUndefinedError;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
    return;
  }

  Future<bool?> showConfirmation(
    BuildContext context, {
    String title = '',
    String message = '',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        final theme = Theme.of(context);

        return AppAlertDialog(
          title: Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: isDestructive ? theme.colorScheme.error : null,
            ),
          ),
          content: Text(
            message,
            style: theme.textTheme.bodyLarge,
            textAlign: .center,
          ),

          actions: [
            CupertinoButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                context.l10n.commonButtonCancel,
                style: theme.textTheme.titleMedium?.copyWith(
                  inherit: false,
                  color: theme.colorScheme.primary,
                  decoration: isDestructive ? TextDecoration.underline : null,
                  decorationColor: isDestructive
                      ? theme.colorScheme.primary
                      : null,
                ),
              ),
            ),
            CupertinoButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                context.l10n.commonButtonOk,
                style: theme.textTheme.titleMedium?.copyWith(
                  inherit: false,
                  color: theme.colorScheme.primary,
                  decoration: isDestructive ? null : TextDecoration.underline,
                  decorationColor: isDestructive
                      ? null
                      : theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

final class AppAlertDialog extends StatelessWidget {
  final Widget? title;
  final Widget? content;
  final List<Widget>? actions;
  final EdgeInsetsGeometry contentPadding;
  // final EdgeInsets? insetPadding;

  const AppAlertDialog({
    super.key,
    this.title,
    this.content,
    this.actions,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 24,
      vertical: 16,
    ),
    // this.insetPadding,
  });

  @override
  Widget build(BuildContext context) {
    final mediaSize = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);

    return AlertDialog(
      constraints: BoxConstraints(
        maxWidth: math.min(400, mediaSize.width * 0.9),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Sizes.indent2x),
      ),
      shadowColor: theme.colorScheme.onSurface,
      elevation: 4.5,
      insetPadding: EdgeInsets.symmetric(
        horizontal: math.max(Sizes.indent2x, 0.1 * mediaSize.width),
      ),
      actionsPadding: const EdgeInsets.only(bottom: Sizes.paddingVariant2x * 2),
      titlePadding: const EdgeInsets.only(
        top: Sizes.paddingVariant2x * 2.0,
        left: Sizes.indentVariant2x * 1.25,
        right: Sizes.indentVariant2x * 1.25,
      ),
      contentPadding: contentPadding,
      backgroundColor: theme.colorScheme.surface,
      title: Center(child: title),

      content: content,
      actionsAlignment: MainAxisAlignment.center,
      alignment: Alignment.center,
      actions: actions,
    );
  }
}
