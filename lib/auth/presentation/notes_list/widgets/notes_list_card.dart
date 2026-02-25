import 'package:flutter/material.dart';
import 'package:nostr_notes/app/sizes.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/auth/presentation/notes_list/bloc/pending_vm.dart';
import 'package:nostr_notes/common/presentation/formatters/date_formatter.dart';
import 'package:nostr_notes/common/presentation/shimmers/common_shimmer_placeholder.dart';

final class NotesListCard extends StatelessWidget {
  static const titleHeight = 24.0;
  static const subtitleHeight = 16.0;
  static const itemHeight = titleHeight + subtitleHeight + Sizes.halfIndent;

  final NoteBase note;
  final PendingVm pendingVm;
  final String? selectedNoteDTag;
  final ValueChanged<NoteBase> onTap;

  const NotesListCard({
    super.key,
    required this.note,
    required this.pendingVm,
    required this.selectedNoteDTag,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleComponents = note.summary.split('\n');
    final title = titleComponents.firstOrNull?.trim() ?? '';
    final subtitle = titleComponents.length > 1
        ? titleComponents[1].trim()
        : '';
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline,
            width: Sizes.thicknessHalf,
          ),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: Sizes.indent2x),
        minVerticalPadding: Sizes.zero,
        trailing: ValueListenableBuilder(
          valueListenable: pendingVm,
          builder: (context, value, child) {
            return Visibility(
              visible: pendingVm.isPending(note.eventId),
              child: const CircularProgressIndicator(),
            );
          },
        ),
        title: Column(
          spacing: Sizes.halfIndent,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: theme.textTheme.titleSmall,
                children: [
                  TextSpan(text: title),
                  if (subtitle.isNotEmpty) ...[
                    const TextSpan(text: '\n'),
                    TextSpan(text: subtitle, style: theme.textTheme.bodyMedium),
                  ],
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(
              height: subtitleHeight,
              child: Text(
                DateFormatter.formatDateTimeOrEmpty(note.createdAt),
                style: theme.textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),

        selected: note.dTag == selectedNoteDTag,
        onTap: () => onTap(note),
      ),
    );
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
