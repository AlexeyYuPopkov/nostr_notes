import 'package:chat/l10n/localization.dart';
import 'package:flutter/material.dart';

enum MessageAction { edit, copy }

abstract final class MessageActionsSheet {
  static const editSemanticsId = 'MessageActionsSheet.edit';
  static const copySemanticsId = 'MessageActionsSheet.copy';

  static Future<MessageAction?> show(
    BuildContext context, {
    required bool canEdit,
  }) {
    return showModalBottomSheet<MessageAction>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (canEdit)
              Semantics(
                identifier: editSemanticsId,
                child: ListTile(
                  leading: const Icon(Icons.edit),
                  title: Text(context.l10n.chatEdit),
                  onTap: () => Navigator.of(context).pop(MessageAction.edit),
                ),
              ),
            Semantics(
              identifier: copySemanticsId,
              child: ListTile(
                leading: const Icon(Icons.copy),
                title: Text(context.l10n.chatCopy),
                onTap: () => Navigator.of(context).pop(MessageAction.copy),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
