import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:nostr_notes/l10n/localization.dart';
import 'package:common/app/theme/sizes.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/auth/presentation/notes_list/bloc/pending_vm.dart';
import 'package:common/presentation/dialogs/common_tooltip.dart';
import 'package:common/presentation/dialogs/dialog_helper.dart';
import 'package:nostr_notes/common/presentation/formatters/date_formatter.dart';
import 'package:nostr_notes/common/presentation/formatters/date_group.dart';
import 'package:nostr_notes/common/presentation/shimmers/common_shimmer_placeholder.dart';
import 'package:common/presentation/tools/list_item_position.dart';

import '../../tools/note_decrypt_error_message_mixin.dart';

final class NotesListCard extends StatelessWidget
    with DialogHelper, NoteDecryptErrorMessageMixin {
  static const titleHeight = 24.0;
  static const subtitleHeight = 16.0;

  final NotesListItem sectionItem;
  final PendingVm pendingVm;
  final String? selectedNoteDTag;
  final ValueChanged<Note> onTap;
  final ValueChanged<Note> onDelete;

  const NotesListCard({
    super.key,
    required this.sectionItem,
    required this.pendingVm,
    required this.selectedNoteDTag,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final isSelected = sectionItem.note.dTag == selectedNoteDTag;
    final hasDecryptError = sectionItem.note.error != null;
    final summary = hasDecryptError
        ? l10n.notePreviewCannotDecryptTitle
        : sectionItem.note.summary;
    final titleComponents = summary.split('\n');
    final title = titleComponents.firstOrNull?.trim() ?? '';
    final subtitle = titleComponents.length > 1
        ? titleComponents[1].trim()
        : '';

    return Container(
      clipBehavior: .hardEdge,
      margin: const EdgeInsets.symmetric(horizontal: Sizes.indent),
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.secondaryContainer
            : theme.colorScheme.outlineVariant,

        borderRadius: sectionItem.position.getRadius(),
        border: sectionItem.position.getBorder(
          theme.colorScheme.outline,
          thickness: Sizes.thicknessHalf,
        ),
      ),
      child: InkWell(
        borderRadius: sectionItem.position.getRadius(),
        onTap: () => onTap(sectionItem.note),

        child: Slidable(
          key: ValueKey(sectionItem.note.dTag),
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            children: [
              SlidableAction(
                onPressed: (context) async {
                  if (await _confirmDismiss(context)) {
                    onDelete(sectionItem.note);
                  }
                },
                backgroundColor: theme.colorScheme.error,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: l10n.commonDelete,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Sizes.indent2x,
              vertical: Sizes.indent,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    spacing: Sizes.halfIndent,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          children: [
                            TextSpan(text: title),
                            if (subtitle.isNotEmpty) ...[
                              const TextSpan(text: '\n'),
                              TextSpan(
                                text: subtitle,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(
                        height: subtitleHeight,
                        child: Text(
                          DateFormatter.formatDateTimeOrEmpty(
                            sectionItem.note.createdAt,
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasDecryptError)
                  CommonTooltip(
                    title: l10n.notePreviewCannotDecryptTitle,
                    message: buildDecryptErrorMessage(
                      l10n: l10n,
                      error: sectionItem.note.error,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: Sizes.indent),
                      child: Icon(
                        Icons.error_outline,
                        size: Sizes.iconMedium,
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                ValueListenableBuilder(
                  valueListenable: pendingVm,
                  builder: (context, value, child) {
                    return Visibility(
                      visible: pendingVm.isPending(sectionItem.note.eventId),
                      child: Padding(
                        padding: const EdgeInsets.only(left: Sizes.indent),
                        child: CommonTooltip(
                          title: context.l10n.notesListPendingSyncTitle,
                          message: context.l10n.notesListPendingSyncDescription,
                          child: const Icon(
                            Icons.schedule,
                            size: Sizes.iconSmall,
                            color: Colors.amber,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmDismiss(BuildContext context) async {
    final l10n = context.l10n;
    final result = await showConfirmation(
      context,
      isDestructive: true,
      title: l10n.commonAttention,
      message: l10n.notesListConfirmationDialogDeletion,
    );
    return result ?? false;
  }
}

final class NotesListCardShimmer extends StatelessWidget {
  static const double subtitleWidth = 70.0;

  final double randomWidth;
  final ListItemPosition position;

  const NotesListCardShimmer({
    super.key,
    required this.position,
    required this.randomWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: .hardEdge,
      margin: const EdgeInsets.symmetric(horizontal: Sizes.indent),
      decoration: BoxDecoration(borderRadius: position.getRadius()),
      child: InkWell(
        borderRadius: position.getRadius(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Sizes.indent),
          child: Column(
            spacing: Sizes.halfIndent,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonShimmer(
                child: SizedBox(
                  height: NotesListCard.titleHeight,
                  width: randomWidth,
                ),
              ),
              const CommonShimmer(
                child: SizedBox(
                  height: NotesListCard.subtitleHeight,
                  width: subtitleWidth,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
