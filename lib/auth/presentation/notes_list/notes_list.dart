import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nostr_notes/app/router/app_router_path.dart';
import 'package:nostr_notes/app/sizes.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/common/presentation/dialogs/dialog_helper.dart';
import 'package:nostr_notes/common/presentation/formatters/date_formatter.dart';

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
              child: ListView.builder(
                itemCount: state.data.notes.length,
                itemBuilder: (context, index) {
                  final note = state.data.notes[index];
                  return ListTile(
                    title: Text(
                      note.summary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      DateFormatter.formatDateTimeOrEmpty(note.createdAt),
                    ),
                    selected: note.dTag == selectedNoteDTag,
                    onTap: () => onTap(note),
                  );
                },
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
