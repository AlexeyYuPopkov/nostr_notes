import 'package:flutter/material.dart';
import 'package:nostr_notes/app/l10n/localization.dart';
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
