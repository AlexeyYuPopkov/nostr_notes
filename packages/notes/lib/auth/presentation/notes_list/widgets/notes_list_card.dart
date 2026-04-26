import 'package:common/l10n/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:nostr_notes/auth/domain/model/category.dart';
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
  static const titleHeight = 26.0;
  static const subtitleHeight = 18.0;

  final NotesListItem sectionItem;
  final PendingVm pendingVm;
  final bool isSelected;
  final bool isNextSelected;
  final ValueChanged<Note> onTap;
  final ValueChanged<Note> onDelete;
  final Stream<Category> Function(Note) getSymbol;

  const NotesListCard({
    super.key,
    required this.sectionItem,
    required this.pendingVm,
    required this.isSelected,
    required this.isNextSelected,
    required this.onTap,
    required this.onDelete,
    required this.getSymbol,
  });

  @override
  Widget build(BuildContext context) {
    const lineHeight = 1.5;
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final commonL10n = context.commonL10n;

    final hasDecryptError = sectionItem.note.error != null;

    final needsSeparator =
        sectionItem.position.needsSeparator() && !isSelected && !isNextSelected;

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
                label: commonL10n.commonDelete,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(
              left: Sizes.indent2x,
              top: Sizes.indent,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: needsSeparator
                    ? Border(
                        bottom: BorderSide(
                          color: theme.colorScheme.outline,
                          width: Sizes.thicknessHalf,
                        ),
                      )
                    : null,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      spacing: Sizes.halfIndent,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Title(
                          sectionItem: sectionItem,
                          getSymbol: getSymbol,
                          onTap: () => onTap(sectionItem.note),
                        ),
                        SizedBox(
                          height: subtitleHeight,
                          child: Text(
                            DateFormatter.formatDateTimeOrEmpty(
                              sectionItem.note.createdAt,
                            ),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w400,
                              color: theme.colorScheme.onSurfaceVariant,
                              height: lineHeight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(height: Sizes.indent),
                      ],
                    ),
                  ),
                  if (hasDecryptError)
                    CommonTooltip(
                      title: l10n.notePreviewCannotDecryptTitle,
                      message: buildDecryptErrorMessage(
                        l10n: l10n,
                        commonL10n: commonL10n,
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
                        child: CommonTooltip(
                          title: context.l10n.notesListPendingSyncTitle,
                          message: context.l10n.notesListPendingSyncDescription,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: Sizes.indent,
                              vertical: Sizes.indent,
                            ),
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
      ),
    );
  }

  Future<bool> _confirmDismiss(BuildContext context) async {
    final l10n = context.l10n;
    final commonL10n = context.commonL10n;
    final result = await showConfirmation(
      context,
      isDestructive: true,
      title: commonL10n.commonAttention,
      message: l10n.notesListConfirmationDialogDeletion,
    );
    return result ?? false;
  }
}

final class _Title extends StatelessWidget {
  final NotesListItem sectionItem;
  final Stream<Category> Function(Note) getSymbol;
  final VoidCallback onTap;

  const _Title({
    required this.sectionItem,
    required this.getSymbol,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const lineHeight = 1.5;
    final theme = Theme.of(context);
    final l10n = context.l10n;

    final hasDecryptError = sectionItem.note.error != null;

    return StreamBuilder(
      stream: getSymbol(sectionItem.note),
      builder: (context, snapshot) {
        final Category? category = snapshot.data;
        final summary = hasDecryptError
            ? l10n.notePreviewCannotDecryptTitle
            : sectionItem.note.summary;
        final titleComponents = summary.split('\n');

        final title = category == null
            ? titleComponents.firstOrNull?.trim() ?? ''
            : '${category.symbol} ${titleComponents.firstOrNull?.trim() ?? ''}'
                  .trim();

        final subtitle = titleComponents.length > 1
            ? titleComponents
                  .skip(1)
                  .firstWhere(
                    (component) => component.trim().isNotEmpty,
                    orElse: () => '',
                  )
                  .trim()
            : '';

        final richText = RichText(
          text: TextSpan(
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              height: lineHeight,
            ),
            children: [
              TextSpan(text: title),
              if (subtitle.isNotEmpty) ...[
                const TextSpan(text: '\n'),
                TextSpan(
                  text: subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w400,
                    color: theme.colorScheme.onSurfaceVariant,
                    height: lineHeight,
                  ),
                ),
              ],
            ],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        );

        return category == null
            ? richText
            : Stack(
                children: [
                  richText,
                  CommonTooltip(
                    title: category.getLocalizedName(context),
                    message: '',
                    margin: EdgeInsets.zero,
                    onTap: onTap,
                    child: SizedBox(
                      height: Sizes.defaultRowHeight,
                      width: Sizes.defaultRowHeight,
                    ),
                  ),
                ],
              );
      },
    );
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
          padding: const EdgeInsets.symmetric(vertical: Sizes.indentVariant2x),
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

extension on Category {
  String getLocalizedName(BuildContext context) {
    final l10n = context.l10n;
    switch (name) {
      case 'finance':
        return l10n.classificationClassFinance;
      case 'journal':
        return l10n.classificationClassJournal;
      case 'personal':
        return l10n.classificationClassPersonal;
      case 'security':
        return l10n.classificationClassSecurity;
      case 'travel':
        return l10n.classificationClassTravel;
      case 'work':
        return l10n.classificationClassWork;
      case 'bookmarks':
        return l10n.classificationClassBookmarks;
      default:
        return l10n.classificationClassOther;
    }
  }
}
