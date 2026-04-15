import 'package:common/l10n/localization.dart';
import 'package:common/presentation/widgets/markdown/gpt_markdown_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/l10n/localization.dart';
import 'package:nostr_notes/app/router/app_route/route_handler.dart';
import 'package:nostr_notes/app/router/note_router.dart';
import 'package:common/app/theme/sizes.dart';
import 'package:nostr_notes/auth/presentation/model/path_params.dart';
import 'package:nostr_notes/auth/presentation/tools/note_decrypt_error_message_mixin.dart';
import 'package:nostr_notes/auth/presentation/note_preview_screen/bloc/note_preview_bloc.dart';
import 'package:nostr_notes/auth/presentation/note_preview_screen/bloc/note_preview_state.dart';
import 'package:common/presentation/widgets/markdown/note_code_field.dart';
import 'package:common/presentation/buttons/refresh_button/refresh_button.dart';

import 'package:common/presentation/dialogs/dialog_helper.dart';
import 'package:nostr_notes/common/presentation/layout/app_platform.dart';

import 'bloc/note_preview_event.dart';

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
                if (const AppPlatform().isDesktopLayout)
                  RefreshButton(
                    vm: context.read<NotePreviewBloc>().refreshButtonVm,
                    padding: const EdgeInsets.symmetric(
                      horizontal: Sizes.indent2x,
                    ),
                    alignment: Alignment.centerRight,
                  ),
                _InfoButton(
                  onPressed: note == null || state is CannotDecryptState
                      ? null
                      : () => _onInfo(context, note.eventId),
                ),
                _EditButton(
                  onPressed: note == null || state is CannotDecryptState
                      ? null
                      : () => _onEdit(context, note.dTag),
                ),
                const SizedBox(width: Sizes.indent2x),
              ],
            ),
            body: SafeArea(
              bottom: false,
              child: ConstrainedBox(
                constraints: const BoxConstraints.expand(),
                child: state is CannotDecryptState
                    ? _CannotDecryptPlaceholder(error: note?.error)
                    : RefreshIndicator.adaptive(
                        onRefresh: () async => _onRefresh(context),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.only(
                            left: Sizes.indent2x,
                            right: Sizes.indent2x,
                            bottom:
                                mediaPaddings.bottom +
                                kFloatingActionButtonMargin +
                                Sizes.fabSize,
                          ),
                          child: SelectionArea(
                            child: GptMarkdownWidget(
                              md: content,
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
            ),
          );
        },
      ),
    );
  }

  void _onEdit(BuildContext context, String noteId) {
    RouteHandler.of(
      context,
    )?.onRoute(NoteDetailsRoute(noteId: noteId), context);
  }

  Future _onRefresh(BuildContext context) async {
    context.read<NotePreviewBloc>().add(const NotePreviewEvent.refresh());
    await Future.delayed(Durations.extralong1);
  }

  void _onInfo(BuildContext context, String eventId) {
    RouteHandler.of(context)?.onRoute(RawEventRoute(eventId: eventId), context);
  }
}

final class _EditButton extends StatelessWidget {
  final VoidCallback? onPressed;
  const _EditButton({this.onPressed});

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
      child: Text(context.commonL10n.commonButtonEdit),
    );
  }
}

final class _InfoButton extends StatelessWidget {
  final VoidCallback? onPressed;
  const _InfoButton({this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CupertinoButton(
      minimumSize: Size.zero,
      padding: const EdgeInsets.symmetric(
        horizontal: Sizes.indent2x,
        vertical: Sizes.indent,
      ),
      onPressed: onPressed,
      child: Icon(
        Icons.info_outline_rounded,
        size: Sizes.iconMedium,
        color: theme.colorScheme.onSurfaceVariant,
      ),
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
    final commonL10n = context.commonL10n;

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
                  commonL10n.authError,
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
                  buildDecryptErrorMessage(
                    l10n: l10n,
                    commonL10n: commonL10n,
                    error: error,
                  ),
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
