import 'dart:math' as math;

import 'package:common/domain/error/app_error.dart';
import 'package:common/l10n/localization.dart';
import 'package:flutter/material.dart';
import 'package:common/app/theme/sizes.dart';

import 'dialog_button.dart';

mixin DialogHelper {
  Future<dynamic> showError(
    BuildContext context, {
    required Object error,
    String? Function(Object? error)? messageBuilder,
  }) async {
    final message =
        (messageBuilder != null ? messageBuilder(error) : null) ??
        (error is AppError
            ? error.message.isNotEmpty
                  ? error.message
                  : context.commonL10n.commonUndefinedError
            : context.commonL10n.commonUndefinedError);

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
          contentPadding: const EdgeInsets.all(Sizes.indent2x),
          title: Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: isDestructive ? theme.colorScheme.error : null,
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: Sizes.indent),
            child: Text(
              message,
              style: theme.textTheme.bodyLarge,
              textAlign: .center,
            ),
          ),

          actions: [
            DialogTextButtonUnderlined(
              text: context.commonL10n.commonButtonCancel,
              onPressed: () => Navigator.of(context).pop(false),
            ),
            DialogTextButton(
              text: context.commonL10n.commonButtonOk,
              onPressed: () => Navigator.of(context).pop(true),
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
      backgroundColor: theme.scaffoldBackgroundColor,
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
      actionsPadding: const EdgeInsets.only(bottom: Sizes.paddingVariant2x),
      titlePadding: const EdgeInsets.only(
        top: Sizes.indentVariant4x,
        left: Sizes.indentVariant2x * 1.25,
        right: Sizes.indentVariant2x * 1.25,
      ),
      contentPadding: contentPadding,

      title: Center(child: title),

      content: content,
      actionsAlignment: MainAxisAlignment.center,
      alignment: Alignment.center,
      actions: actions,
    );
  }
}
