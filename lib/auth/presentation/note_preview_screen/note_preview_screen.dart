import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:nostr_notes/app/l10n/localization.dart';
import 'package:nostr_notes/app/router/app_route/route_handler.dart';
import 'package:nostr_notes/app/router/note_router.dart';
import 'package:nostr_notes/app/sizes.dart';
import 'package:nostr_notes/app/theme/gpt_markdown_theme_data.dart';
import 'package:nostr_notes/auth/presentation/model/path_params.dart';
import 'package:nostr_notes/auth/presentation/tools/note_decrypt_error_message_mixin.dart';
import 'package:nostr_notes/auth/presentation/note_preview_screen/bloc/note_preview_bloc.dart';
import 'package:nostr_notes/auth/presentation/note_preview_screen/bloc/note_preview_state.dart';
import 'package:nostr_notes/auth/presentation/note_preview_screen/widgets/note_code_field.dart';

import 'package:nostr_notes/common/presentation/dialogs/dialog_helper.dart';

final class NotePreviewScreen extends StatelessWidget with DialogHelper {
  final PathParams pathParams;

  NotePreviewScreen({super.key, required this.pathParams});

  void _listener(BuildContext context, NotePreviewState state) {
    switch (state) {
      case CommonState():
      case LoadingState():
      case CannotDecryptState():
        break;
      case ErrorState():
        showError(context, error: state.error);
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
          final mediaPaddings = MediaQuery.paddingOf(context);
          return Scaffold(
            backgroundColor: theme.colorScheme.surface,
            appBar: AppBar(
              actions: [
                _SaveButton(
                  onPressed: note == null || state is CannotDecryptState
                      ? null
                      : () => _onSave(context, note.dTag),
                ),
                const SizedBox(width: Sizes.indent2x),
              ],
            ),
            body: SafeArea(
              bottom: false,
              child: state is CannotDecryptState
                  ? _CannotDecryptPlaceholder(error: note?.error)
                  : SingleChildScrollView(
                      padding: EdgeInsets.only(
                        left: Sizes.indent2x,
                        right: Sizes.indent2x,
                        bottom:
                            mediaPaddings.bottom +
                            kFloatingActionButtonMargin +
                            Sizes.fabSize,
                      ),
                      child: SelectionArea(
                        child: GptMarkdownTheme(
                          gptThemeData: AppGptMarkdownTheme.light().data,
                          child: GptMarkdown(
                            content,
                            codeBuilder: (context, name, code, closed) {
                              return NoteCodeField(name: name, codes: code);
                            },
                            highlightBuilder: (context, code, closed) {
                              return ShortNoteCodeField(codes: code);
                            },
                          ),
                        ),
                      ),
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
      padding: const EdgeInsets.only(
        left: Sizes.indent2x,
        right: Sizes.indent,
        top: Sizes.indent,
        bottom: Sizes.indent,
      ),
      onPressed: onPressed,
      child: Text(context.l10n.commonButtonEdit),
    );
  }
}

final class _CannotDecryptPlaceholder extends StatelessWidget
    with NoteDecryptErrorMessageMixin {
  final Object? error;

  const _CannotDecryptPlaceholder({this.error});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(Sizes.padding2x),
          child: Padding(
            padding: const EdgeInsets.all(Sizes.padding2x),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: Sizes.icon,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: Sizes.indent2x),
                Text(
                  l10n.authError,
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Sizes.indent),
                Text(
                  l10n.notePreviewCannotDecryptTitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Sizes.indent2x),
                Text(
                  buildDecryptErrorMessage(l10n: l10n, error: error),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
