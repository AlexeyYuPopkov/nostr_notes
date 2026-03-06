import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nostr_notes/app/icons/app_icons.dart';
import 'package:nostr_notes/app/l10n/localization.dart';
import 'package:nostr_notes/app/router/app_route/route_handler.dart';
import 'package:nostr_notes/app/router/drawer_router.dart';
import 'package:nostr_notes/app/sizes.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/common/presentation/dialogs/dialog_helper.dart';
import 'package:nostr_notes/common/presentation/formatters/date_group.dart';

import 'bloc/notes_list_bloc.dart';
import 'bloc/notes_list_event.dart';
import 'bloc/notes_list_state.dart';
import 'widgets/notes_list_card.dart';
import 'widgets/notes_list_section_header.dart';

final class NotesList extends StatelessWidget with DialogHelper {
  final String? selectedNoteDTag;
  final ValueChanged<NoteBase> onTap;
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
    return BlocProvider(
      create: (context) => NotesListBloc(contextProvider: () => context),
      child: BlocConsumer<NotesListBloc, NotesListState>(
        listener: _listener,
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(context.l10n.notesListScreenTitle),
              actions: const [_SettingsButton()],
            ),
            body: RefreshIndicator(
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

  void _onRefresh(BuildContext context) {
    context.read<NotesListBloc>().add(const NotesListEvent.initial());
  }
}

final class _List extends StatelessWidget {
  static const _placeholdersCount = 9;

  const _List({
    required this.selectedNoteDTag,
    required this.isLoading,
    required this.sections,
    required this.onTap,
  });

  final String? selectedNoteDTag;
  final bool isLoading;
  final List<NotesListSection> sections;
  final ValueChanged<NoteBase> onTap;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return ListView.builder(
        itemCount: _placeholdersCount,
        cacheExtent: NotesListCard.itemHeight,
        itemBuilder: (context, index) => const NotesListCardShimmer(),
      );
    }

    final bloc = context.read<NotesListBloc>();
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      cacheExtent: NotesListCard.itemHeight,
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
      ],
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
        AppIcons.profileIcon,
        width: Sizes.icon,
        height: Sizes.icon,
        colorFilter: ColorFilter.mode(
          theme.colorScheme.primary,
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
