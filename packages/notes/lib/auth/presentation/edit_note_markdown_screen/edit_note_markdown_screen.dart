import 'dart:async';

import 'package:common/l10n/localization.dart';
import 'package:common/presentation/dialogs/dialog_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/l10n/localization.dart';
import 'package:common/app/theme/sizes.dart';
import 'package:common/app/theme/gpt_markdown_theme_data.dart';
import 'package:nostr_notes/auth/presentation/model/path_params.dart';

import 'bloc/markdown_edit_note_bloc.dart';
import 'bloc/markdown_edit_note_event.dart';
import 'bloc/markdown_edit_note_state.dart';
import 'tools/edit_note_formatters.dart';

abstract interface class EditMarkdownNoteScreenCoordinator {
  FutureOr<dynamic> onNotePreviewRoute(
    BuildContext context, {
    required String noteId,
  });
}

final class EditMarkdownNoteScreen extends StatelessWidget with DialogHelper {
  final EditMarkdownNoteScreenCoordinator coordinator;
  final PathParams? pathParams;

  EditMarkdownNoteScreen({
    super.key,
    this.pathParams,
    required this.coordinator,
  });

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.editNoteScreenSaveSuccess)),
        );

        final noteId = pathParams?.id ?? '';
        final isNew = noteId.isEmpty;

        if (isNew) {
          // RouteHandler.of(
          //   context,
          // )?.onRoute(NotePreviewRoute(noteId: state.note.dTag), context);

          coordinator.onNotePreviewRoute(context, noteId: state.note.dTag);
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
                  inputFormatters: EditNoteFormatters.content,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    fillColor: theme.colorScheme.surface,
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
          child: Text(context.commonL10n.commonButtonSave),
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
