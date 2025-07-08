import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nostr_notes/app/router/app_router_path.dart';
import 'package:nostr_notes/app/sizes.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/common/presentation/dialogs/dialog_helper.dart';
import 'package:nostr_notes/common/presentation/formatters/date_formatter.dart';
import 'package:nostr_notes/common/presentation/shimmers/common_shimmer_placeholder.dart';

import 'bloc/notes_list_bloc.dart';
import 'bloc/notes_list_event.dart';
import 'bloc/notes_list_state.dart';

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
      create: (context) => NotesListBloc(),
      child: BlocConsumer<NotesListBloc, NotesListState>(
        listener: _listener,
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Заметки'),
              actions: const [_NewNote()],
            ),
            body: RefreshIndicator(
              onRefresh: () async => _onRefresh(context),
              child: _List(
                selectedNoteDTag: selectedNoteDTag,
                isLoading: state is LoadingState,
                notes: state.data.notes,
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
  static const titleHeight = 24.0;
  static const subtitleHeight = 16.0;
  static const itemHeight = titleHeight + subtitleHeight;

  const _List({
    required this.selectedNoteDTag,
    required this.isLoading,
    required this.notes,
    required this.onTap,
  });

  final String? selectedNoteDTag;
  final bool isLoading;
  final List<NoteBase> notes;
  final ValueChanged<NoteBase> onTap;

  @override
  Widget build(BuildContext context) {
    const placeholdersCount = 9;

    final count = isLoading ? placeholdersCount : notes.length;
    final theme = Theme.of(context);
    return ListView.separated(
      itemCount: count,
      cacheExtent: itemHeight,
      itemBuilder: (context, index) {
        if (isLoading) {
          return const _Shimmer();
        }

        final note = notes[index];
        return SizedBox(
          height: itemHeight,
          child: ListTile(
            title: SizedBox(
              height: titleHeight,
              child: Text(
                note.summary,
                style: theme.textTheme.titleSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            subtitle: SizedBox(
              height: subtitleHeight,
              child: Text(
                DateFormatter.formatDateTimeOrEmpty(note.createdAt),
                style: theme.textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            selected: note.dTag == selectedNoteDTag,
            onTap: () => onTap(note),
          ),
        );
      },
      separatorBuilder: (context, index) =>
          const SizedBox(height: Sizes.indentVariant2x),
    );
  }
}

final class _Shimmer extends StatelessWidget {
  const _Shimmer();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: _List.itemHeight,
      child: ListTile(
        title: CommonShimmer(
          child: SizedBox(
            height: _List.titleHeight,
            width: double.infinity,
          ),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: Sizes.halfIndent),
          child: CommonShimmer(
            child: SizedBox(
              height: _List.subtitleHeight,
              width: double.infinity,
            ),
          ),
        ),
      ),
    );
  }
}

final class _NewNote extends StatelessWidget {
  const _NewNote();

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      child: const Icon(
        Icons.edit_note,
        size: Sizes.icon,
      ),
      onPressed: () => _onNewNote(context),
    );
  }

  void _onNewNote(BuildContext context) {
    GoRouter.of(context).push(AppRouterPath.note);
  }
}
