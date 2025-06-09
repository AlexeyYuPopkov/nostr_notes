import 'package:flutter/material.dart';
import 'package:nostr_notes/app/l10n/localization.dart';
import 'package:nostr_notes/common/domain/error/app_error.dart';

mixin DialogHelper {
  Future<dynamic> showError(
    BuildContext context, {
    required Object error,
  }) {
    return showDialog<dynamic>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        final message = error is AppError
            ? error.message.isNotEmpty
                ? error.message
                : context.l10n.commonUndefinedError
            : context.l10n.commonUndefinedError;
        return AlertDialog(
          title: Text(context.l10n.commonError),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.l10n.commonButtonOk),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> showConfirmation(
    BuildContext context, {
    String title = '',
    String message = '',
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(context.l10n.commonButtonCancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(context.l10n.commonButtonOk),
            ),
          ],
        );
      },
    );
  }
}
