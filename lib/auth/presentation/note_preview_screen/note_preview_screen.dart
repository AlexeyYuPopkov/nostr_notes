import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:nostr_notes/app/l10n/localization.dart';
import 'package:nostr_notes/app/router/app_route/route_handler.dart';
import 'package:nostr_notes/app/router/note_router.dart';
import 'package:nostr_notes/app/sizes.dart';
import 'package:nostr_notes/auth/presentation/model/path_params.dart';
import 'package:nostr_notes/auth/presentation/note_preview_screen/bloc/note_preview_bloc.dart';
import 'package:nostr_notes/auth/presentation/note_preview_screen/bloc/note_preview_state.dart';

import 'package:nostr_notes/common/presentation/dialogs/dialog_helper.dart';

final class NotePreviewScreen extends StatelessWidget with DialogHelper {
  final PathParams pathParams;

  NotePreviewScreen({super.key, required this.pathParams});

  void _listener(BuildContext context, NotePreviewState state) {
    switch (state) {
      case CommonState():
        break;
      case LoadingState():
        break;
      case ErrorState():
        showError(context, error: state.e);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocProvider(
      create: (context) => NotePreviewBloc(pathParams: pathParams),
      child: BlocConsumer<NotePreviewBloc, NotePreviewState>(
        listener: _listener,
        builder: (context, state) {
          final note = state.data.note.value;
          final content = note?.content ?? '';
          return Scaffold(
            backgroundColor: theme.colorScheme.surface,
            appBar: AppBar(
              actions: [
                _SaveButton(
                  onPressed: note == null
                      ? null
                      : () => _onSave(context, note.dTag),
                ),
                const SizedBox(width: Sizes.indent2x),
              ],
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(Sizes.indent),
                child: GptMarkdown(content),
              ),
            ),
          );
        },
      ),
    );
  }

  void _onSave(BuildContext context, String noteId) {
    RouteHandler.of(
      context,
    )?.onRoute(NoteDetailsRoute(noteId: noteId), context);
  }
}

final class _SaveButton extends StatelessWidget {
  final VoidCallback? onPressed;
  const _SaveButton({this.onPressed});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      minimumSize: Size.zero,
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Text(context.l10n.commonButtonEdit),
    );
  }
}
