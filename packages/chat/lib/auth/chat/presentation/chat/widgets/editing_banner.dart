import 'package:chat/l10n/localization.dart';
import 'package:common/app/theme/sizes.dart';
import 'package:flutter/material.dart';

final class EditingBanner extends StatelessWidget {
  static const cancelButtonSemanticsId = 'ChatScreen.cancelEditingButton';

  final VoidCallback onCancel;

  const EditingBanner({super.key, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(left: Sizes.indent2x),
      child: Row(
        children: [
          Icon(
            Icons.edit,
            size: Sizes.iconMedium,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: Sizes.indent),
          Expanded(
            child: Text(
              context.l10n.chatEditing,
              style: theme.textTheme.labelLarge,
            ),
          ),
          Semantics(
            identifier: cancelButtonSemanticsId,
            child: IconButton(
              icon: const Icon(Icons.close),
              tooltip: context.l10n.chatCancelEditing,
              onPressed: onCancel,
            ),
          ),
        ],
      ),
    );
  }
}

final class EditedLabel extends StatelessWidget {
  const EditedLabel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      context.l10n.chatEdited,
      style: theme.textTheme.labelSmall?.copyWith(
        fontStyle: FontStyle.italic,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
