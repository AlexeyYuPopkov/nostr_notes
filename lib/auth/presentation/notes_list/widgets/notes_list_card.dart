import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:nostr_notes/app/l10n/localization.dart';
import 'package:nostr_notes/app/sizes.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/auth/presentation/notes_list/bloc/pending_vm.dart';
import 'package:nostr_notes/common/presentation/dialogs/common_tooltip.dart';
import 'package:nostr_notes/common/presentation/dialogs/dialog_helper.dart';
import 'package:nostr_notes/common/presentation/formatters/date_formatter.dart';
import 'package:nostr_notes/common/presentation/formatters/date_group.dart';
import 'package:nostr_notes/common/presentation/shimmers/common_shimmer_placeholder.dart';

final class NotesListCard extends StatelessWidget with DialogHelper {
  static const titleHeight = 24.0;
  static const subtitleHeight = 16.0;
  static const itemHeight = titleHeight + subtitleHeight + Sizes.halfIndent;

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
    final isSelected = sectionItem.note.dTag == selectedNoteDTag;
    final titleComponents = sectionItem.note.summary.split('\n');
    final title = titleComponents.firstOrNull?.trim() ?? '';
    final subtitle = titleComponents.length > 1
        ? titleComponents[1].trim()
        : '';
    final showBottomBorder =
        sectionItem.position == NotesListItemPosition.middle ||
        sectionItem.position == NotesListItemPosition.first;

    return Container(
      clipBehavior: .hardEdge,
      margin: const EdgeInsets.symmetric(horizontal: Sizes.indent),
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.secondaryContainer
            : theme.colorScheme.outlineVariant,

        borderRadius: _getRadius(sectionItem.position),
        border: showBottomBorder
            ? Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outline,
                  width: Sizes.thicknessHalf,
                ),
              )
            : null,
      ),
      child: InkWell(
        borderRadius: _getRadius(sectionItem.position),
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
                label: 'Delete',
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
                ValueListenableBuilder(
                  valueListenable: pendingVm,
                  builder: (context, value, child) {
                    return Visibility(
                      visible: pendingVm.isPending(sectionItem.note.eventId),
                      child: CommonTooltip(
                        title: context.l10n.notesListPendingSyncTitle,
                        message: context.l10n.notesListPendingSyncDescription,
                        child: const Icon(
                          Icons.schedule,
                          size: Sizes.iconSmall,
                          color: Colors.amber,
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

  BorderRadius _getRadius(NotesListItemPosition position) {
    const radius = Radius.circular(Sizes.radius);
    switch (position) {
      case NotesListItemPosition.single:
        return const BorderRadius.all(radius);

      case NotesListItemPosition.first:
        return const BorderRadius.vertical(top: radius);

      case NotesListItemPosition.last:
        return const BorderRadius.vertical(bottom: radius);

      case NotesListItemPosition.middle:
        return BorderRadius.zero;
    }
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
  const NotesListCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline,
            width: Sizes.thicknessHalf,
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final randomWidth =
              constraints.maxWidth *
              (0.3 + (0.4 * (UniqueKey().hashCode % 1000) / 1000));
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: Sizes.indent2x,
            ),
            minVerticalPadding: Sizes.zero,
            title: Column(
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
          );
        },
      ),
    );
  }
}
