import 'package:common/app/theme/sizes.dart';
import 'package:common/presentation/tools/list_item_position.dart';
import 'package:common/presentation/tools/section_scroll_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/auth/domain/model/label.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/auth/presentation/dashboard/notes/bloc/notes_list_bloc.dart';
import 'package:nostr_notes/auth/presentation/dashboard/notes/bloc/notes_list_event.dart';
import 'package:nostr_notes/auth/presentation/dashboard/notes_list_tab.dart';
import 'package:nostr_notes/auth/presentation/dashboard/widgets/labels_picker.dart';
import 'package:nostr_notes/auth/presentation/dashboard/widgets/notes_list_card.dart';
import 'package:nostr_notes/auth/presentation/dashboard/widgets/notes_list_section_header.dart';
import 'package:nostr_notes/auth/presentation/widgets/home_screen_empty_state_placeholder.dart';
import 'package:nostr_notes/common/presentation/formatters/date_group.dart';
import 'package:nostr_notes/common/presentation/layout/breakpoints.dart';
import 'package:nostr_notes/common/presentation/layout/layout_config.dart';
import 'package:nostr_notes/common/presentation/shimmers/common_shimmer_placeholder.dart';
import 'package:nostr_notes/l10n/localization.dart';

final class NotesTabContent extends StatelessWidget with LabelsPickerHelper {
  final String? selectedNoteDTag;
  final bool isLoading;
  final List<NotesListSection> sections;
  final String searchQuery;
  final bool hasAnyNotes;
  final bool showSearch;
  final bool showFolderFilterChips;
  final ValueChanged<Note> onTap;
  final SectionScrollVm _scrollSectionsVm;

  const NotesTabContent({
    super.key,
    required this.selectedNoteDTag,
    required this.isLoading,
    required this.sections,
    required this.onTap,
    required SectionScrollVm scrollSectionsVm,
    this.searchQuery = '',
    this.hasAnyNotes = false,
    this.showSearch = true,
    this.showFolderFilterChips = false,
  }) : _scrollSectionsVm = scrollSectionsVm;

  double get _headerHeight {
    if (!showSearch) {
      return kNotesListHeaderWithoutSearch;
    }
    return showFolderFilterChips
        ? kNotesListHeaderWithSearchAndFilter
        : kNotesListHeaderWithSearch;
  }

  @override
  Widget build(BuildContext context) {
    final refreshDisplacement = _headerHeight;
    if (isLoading) {
      return _ShimmersList(headerHeight: _headerHeight);
    }

    final hasQuery = showSearch && searchQuery.trim().isNotEmpty;

    if (!hasAnyNotes && !hasQuery) {
      final breakpoint = Breakpoint.activeBreakpointOf(context);
      if (breakpoint.isSmall) {
        return const HomeScreenEmptyStatePlaceholder();
      }
    }

    final mediaPadding = MediaQuery.paddingOf(context);
    final bloc = context.read<NotesListBloc>();

    if (sections.isEmpty && hasQuery) {
      return const _NoSearchResults();
    }

    return RefreshIndicator.adaptive(
      displacement: refreshDisplacement,
      onRefresh: () => _onRefresh(context),
      child: CustomScrollView(
        physics: const _ClampTopScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: _headerHeight)),
          SliverList(
            delegate: SliverChildBuilderDelegate(childCount: sections.length, (
              context,
              index,
            ) {
              final section = sections[index];
              if (section is NotesListHeader) {
                return NotesListSectionHeader(
                  title: section.title,
                  isFirst: index == 0,
                  onBuildSectionTitle: (ctx) =>
                      _scrollSectionsVm.registerSection(section, ctx),
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
            }),
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

final class _ClampTopScrollPhysics extends ScrollPhysics {
  const _ClampTopScrollPhysics({super.parent});

  @override
  _ClampTopScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _ClampTopScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) => true;

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    if (value < position.minScrollExtent &&
        position.minScrollExtent < position.pixels) {
      return value - position.minScrollExtent;
    }
    if (value < position.pixels &&
        position.pixels <= position.minScrollExtent) {
      return value - position.pixels;
    }
    return super.applyBoundaryConditions(position, value);
  }
}

final class _ShimmersList extends StatefulWidget {
  static const _placeholdersCount = 15;
  final double headerHeight;
  const _ShimmersList({required this.headerHeight});

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
      return breakpoint.isSmall
          ? randomWidth
          : LayoutConfig.maxBodyRatio * randomWidth;
    },
  );

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(top: widget.headerHeight),
      itemCount: _ShimmersList._placeholdersCount + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return const _SectionHeaderShimmer();
        }

        final cardIndex = index - 1;

        return NotesListCardShimmer(
          randomWidth: _randomWidths[cardIndex],
          position: ListItemPosition.fromIndex(
            cardIndex,
            length: _ShimmersList._placeholdersCount,
          ),
        );
      },
    );
  }
}

final class _SectionHeaderShimmer extends StatelessWidget {
  const _SectionHeaderShimmer();

  @override
  Widget build(BuildContext context) {
    const shimmerWidth = 120.0;
    return const Padding(
      padding: EdgeInsets.only(
        left: Sizes.indent,
        right: Sizes.indent,
        top: Sizes.indent2x,
        bottom: Sizes.indent,
      ),
      child: Row(
        children: [
          CommonShimmer(
            child: SizedBox(
              height: Sizes.paddingVariant2x,
              width: shimmerWidth,
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }
}

final class _NoSearchResults extends StatelessWidget {
  const _NoSearchResults();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Sizes.indent4x),
      child: Center(
        child: Text(
          context.l10n.notesListSearchNothingFound,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
