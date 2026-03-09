import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/app/l10n/localization.dart';
import 'package:nostr_notes/app/router/app_route/route_handler.dart';
import 'package:nostr_notes/app/router/note_router.dart';
import 'package:nostr_notes/app/sizes.dart';
import 'package:nostr_notes/app/theme/gpt_markdown_theme_data.dart';
import 'package:nostr_notes/auth/presentation/model/path_params.dart';
import 'package:nostr_notes/common/presentation/dialogs/dialog_helper.dart';

import 'bloc/markdown_edit_note_bloc.dart';
import 'bloc/markdown_edit_note_event.dart';
import 'bloc/markdown_edit_note_state.dart';

final class EditMarkdownNoteScreen extends StatelessWidget with DialogHelper {
  final PathParams? pathParams;

  EditMarkdownNoteScreen({super.key, this.pathParams});

  void _listener(BuildContext context, MarkdownEditNoteState state) {
    switch (state) {
      case CommonState():
        break;
      case LoadingState():
        break;
      case ErrorState():
        showError(context, error: state.e);
        break;
      case DidSaveState():
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Saved successfully')));

        final noteId = pathParams?.id ?? '';
        final isNew = noteId.isEmpty;

        if (isNew) {
          RouteHandler.of(
            context,
          )?.onRoute(NotePreviewRoute(noteId: state.note.dTag), context);
        } else {
          Navigator.of(context).pop();
        }

        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final markdownTheme = theme.extension<AppGptMarkdownTheme>()!;
    return BlocProvider(
      create: (context) => MarkdownEditNoteBloc(
        pathParams: pathParams,
        brightness: theme.brightness,
      ),
      child: BlocConsumer<MarkdownEditNoteBloc, MarkdownEditNoteState>(
        listener: _listener,
        builder: (context, state) {
          final bloc = context.read<MarkdownEditNoteBloc>();
          return Scaffold(
            backgroundColor: theme.colorScheme.surface,
            appBar: AppBar(
              actions: const [
                _SaveButton(),
                SizedBox(width: Sizes.indent2x),
              ],
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(Sizes.indent),
                child: TextField(
                  controller: bloc.textController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: markdownTheme.rawCodeTextStyle,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    hintText: 'Enter markdown...',
                  ),
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                  onChanged: (text) {
                    bloc.add(MarkdownEditNoteEvent.textChanged(text));
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

final class _SaveButton extends StatelessWidget {
  const _SaveButton();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<MarkdownEditNoteBloc, MarkdownEditNoteState, bool>(
      selector: (state) => state.data.hasChanges,
      builder: (context, hasChanges) {
        return CupertinoButton(
          minimumSize: Size.zero,
          padding: const EdgeInsets.only(
            left: Sizes.indent2x,
            right: Sizes.indent,
            top: Sizes.indent,
            bottom: Sizes.indent,
          ),
          onPressed: hasChanges ? () => _onSave(context) : null,
          child: Text(context.l10n.commonButtonSave),
        );
      },
    );
  }

  void _onSave(BuildContext context) {
    FocusScope.of(context).unfocus();
    context.read<MarkdownEditNoteBloc>().add(
      const MarkdownEditNoteEvent.save(),
    );
  }
}
