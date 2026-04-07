import 'package:common/app/icons/app_icons.dart';
import 'package:common/presentation/buttons/refresh_button/refresh_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nostr_notes/l10n/localization.dart';
import 'package:nostr_notes/app/router/app_route/route_handler.dart';
import 'package:nostr_notes/app/router/drawer_router.dart';
import 'package:common/app/theme/sizes.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/common/presentation/layout/app_platform.dart';
import 'package:nostr_notes/common/presentation/layout/breakpoints.dart';
import 'package:nostr_notes/auth/presentation/home_screen/fab.dart';
import 'package:nostr_notes/auth/presentation/widgets/new_note_prompt_placeholder.dart';
import 'package:common/presentation/dialogs/dialog_helper.dart';
import 'package:nostr_notes/common/presentation/formatters/date_group.dart';
import 'package:nostr_notes/common/presentation/layout/layout_config.dart';
import 'package:common/presentation/tools/list_item_position.dart';

import 'bloc/notes_list_bloc.dart';
import 'bloc/notes_list_event.dart';
import 'bloc/notes_list_state.dart';
import 'widgets/notes_list_card.dart';
import 'widgets/notes_list_section_header.dart';

final class NotesList extends StatelessWidget with DialogHelper {
  final String? selectedNoteDTag;
  final ValueChanged<Note> onTap;
  const NotesList({
    super.key,
    required this.selectedNoteDTag,
    required this.onTap,
  });

  void _listener(BuildContext context, NotesListState state) {
    switch (state) {
      case CommonState():
      case LoadingState():
        break;
      case ErrorState():
        showError(context, error: state.e);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final breakpoint = Breakpoint.activeBreakpointOf(context);

    return BlocProvider(
      create: (context) => NotesListBloc(contextProvider: () => context),
      child: BlocConsumer<NotesListBloc, NotesListState>(
        listener: _listener,
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(context.l10n.notesListScreenTitle),
              actions: [
                if (const AppPlatform().isDesktopLayout)
                  RefreshButton(
                    vm: context.read<NotesListBloc>().refreshButtonVm,
                    padding: const EdgeInsets.only(left: Sizes.indent2x),
                    alignment: Alignment.centerRight,
                  ),

                const _SettingsButton(),
              ],
            ),
            floatingActionButton: breakpoint.isSmall ? const Fab() : null,
            body: RefreshIndicator.adaptive(
              onRefresh: () async => _onRefresh(context),
              child: _List(
                selectedNoteDTag: selectedNoteDTag,
                isLoading: state is LoadingState,
                sections: state.data.sections,
                onTap: onTap,
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _onRefresh(BuildContext context) {
    context.read<NotesListBloc>().add(const NotesListEvent.initial());
    return Future.delayed(Durations.extralong1);
  }
}

final class _List extends StatelessWidget {
  const _List({
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

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      cacheExtent: 600.0,
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final section = sections[index];
            if (section is NotesListHeader) {
              return NotesListSectionHeader(title: section.title);
            } else if (section is NotesListItem) {
              return NotesListCard(
                pendingVm: bloc.pendingVm,
                sectionItem: section,
                selectedNoteDTag: selectedNoteDTag,
                onTap: onTap,
                onDelete: (note) => bloc.add(NotesListEvent.deleteNote(note)),
              );
            } else {
              return const SizedBox.shrink();
            }
          }, childCount: sections.length),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: Sizes.indent4x)),
        SliverToBoxAdapter(child: SizedBox(height: mediaPadding.bottom)),
      ],
    );
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

      if (breakpoint.isSmall) {
        return _expectedWidth *
            (0.3 + (0.4 * (UniqueKey().hashCode % 1000) / 1000));
      } else {
        return LayoutConfig.maxBodyRatio *
            _expectedWidth *
            (0.3 + (0.4 * (UniqueKey().hashCode % 1000) / 1000));
      }
    },
  );

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _ShimmersList._placeholdersCount,
      itemBuilder: (context, index) => NotesListCardShimmer(
        randomWidth: _randomWidths[index],
        position: ListItemPosition.fromIndex(
          index,
          length: _ShimmersList._placeholdersCount,
        ),
      ),
    );
  }
}

final class _SettingsButton extends StatelessWidget {
  const _SettingsButton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CupertinoButton(
      child: SvgPicture.asset(
        CommonIcons.profileIcon,
        width: Sizes.icon,
        height: Sizes.icon,
        colorFilter: ColorFilter.mode(
          theme.colorScheme.onSurfaceVariant,
          BlendMode.srcIn,
        ),
      ),
      onPressed: () => _onNewNote(context),
    );
  }

  void _onNewNote(BuildContext context) {
    RouteHandler.of(context)?.onRoute(const OnEndDrawer(), context);
  }
}
