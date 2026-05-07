import 'package:common/app/theme/sizes.dart';
import 'package:common/presentation/tools/list_item_position.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/auth/domain/model/label.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/auth/presentation/notes_list/bloc/notes_list_bloc.dart';
import 'package:nostr_notes/auth/presentation/notes_list/bloc/notes_list_event.dart';
import 'package:nostr_notes/auth/presentation/notes_list/widgets/labels_picker.dart';
import 'package:nostr_notes/auth/presentation/notes_list/widgets/notes_list_card.dart';
import 'package:nostr_notes/auth/presentation/notes_list/widgets/notes_list_section_header.dart';
import 'package:nostr_notes/auth/presentation/widgets/new_note_prompt_placeholder.dart';
import 'package:nostr_notes/common/presentation/formatters/date_group.dart';
import 'package:nostr_notes/common/presentation/layout/breakpoints.dart';
import 'package:nostr_notes/common/presentation/layout/layout_config.dart';

final class AllTabContent extends StatelessWidget with LabelsPickerHelper {
  const AllTabContent({
    super.key,
    required this.selectedNoteDTag,
    required this.isLoading,
    required this.sections,
    required this.onTap,
  });

  final String? selectedNoteDTag;
  final bool isLoading;
  final List<NotesListSection> sections;
  final ValueChanged<Note> onTap;

  @override
  Widget build(BuildContext context) {
    const refreshDisplacement = 80.0;
    if (isLoading) {
      return const _ShimmersList();
    }

    if (sections.isEmpty) {
      final breakpoint = Breakpoint.activeBreakpointOf(context);
      if (breakpoint.isSmall) {
        return const NewNotePromptPlaceholder();
      }
    }

    final mediaPadding = MediaQuery.paddingOf(context);
    final bloc = context.read<NotesListBloc>();

    return RefreshIndicator.adaptive(
      displacement: refreshDisplacement,
      onRefresh: () => _onRefresh(context),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        cacheExtent: 600.0,
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final section = sections[index];
              if (section is NotesListHeader) {
                return NotesListSectionHeader(
                  title: section.title,
                  isFirst: index == 0,
                );
              } else if (section is NotesListItem) {
                final isSelected = section.note.dTag == selectedNoteDTag;
                final nextSection = index + 1 < sections.length
                    ? sections[index + 1]
                    : null;

                final isNextSelected =
                    nextSection is NotesListItem &&
                    nextSection.note.dTag == selectedNoteDTag;

                return NotesListCard(
                  pendingVm: bloc.pendingVm,
                  sectionItem: section,
                  isSelected: isSelected,
                  isNextSelected: isNextSelected,
                  onTap: onTap,
                  onDelete: (note) => bloc.add(NotesListEvent.deleteNote(note)),
                  onAssignLabels: (note, btnContext) => showLabelsPicker(
                    btnContext,
                    note: note,
                    onApply: (labels) => _onApplyLabels(context, note, labels),
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            }, childCount: sections.length),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: Sizes.indent4x)),
          SliverToBoxAdapter(child: SizedBox(height: mediaPadding.bottom)),
        ],
      ),
    );
  }

  Future<void> _onRefresh(BuildContext context) {
    context.read<NotesListBloc>().add(const NotesListEvent.refresh());
    return Future.delayed(Durations.extralong1);
  }

  void _onApplyLabels(
    BuildContext context,
    Note note,
    List<CategoryType> labels,
  ) {
    final bloc = context.read<NotesListBloc>();
    bloc.add(NotesListEvent.assignLabels(note: note, labels: labels));
  }
}

final class _ShimmersList extends StatefulWidget {
  static const _placeholdersCount = 15;
  const _ShimmersList();

  @override
  State<_ShimmersList> createState() => _ShimmersListState();
}

final class _ShimmersListState extends State<_ShimmersList> {
  late final _expectedWidth = MediaQuery.sizeOf(context).width - Sizes.indent2x;
  late final List<double> _randomWidths = List.generate(
    _ShimmersList._placeholdersCount,
    (_) {
      final breakpoint = Breakpoint.activeBreakpointOf(context);

      final randomWidth =
          _expectedWidth * (0.3 + (0.4 * (UniqueKey().hashCode % 1000) / 1000));

      if (breakpoint.isSmall) {
        return randomWidth;
      } else {
        return LayoutConfig.maxBodyRatio * randomWidth;
      }
    },
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Sizes.indent4x),
      child: ListView.builder(
        itemCount: _ShimmersList._placeholdersCount,
        itemBuilder: (context, index) => NotesListCardShimmer(
          randomWidth: _randomWidths[index],
          position: ListItemPosition.fromIndex(
            index,
            length: _ShimmersList._placeholdersCount,
          ),
        ),
      ),
    );
  }
}
