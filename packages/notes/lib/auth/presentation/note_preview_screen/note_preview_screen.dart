import 'dart:async';

import 'package:common/l10n/localization.dart';
import 'package:common/presentation/dialogs/dialog_helper.dart';
import 'package:common/presentation/widgets/common_popup_menu_button.dart';
import 'package:common/presentation/widgets/markdown/gpt_markdown_widget.dart';
import 'package:common/presentation/widgets/progress_hud/progress_hud.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/auth/domain/model/label.dart';
import 'package:nostr_notes/auth/presentation/notes_list/widgets/labels_picker.dart';
import 'package:nostr_notes/auth/presentation/settings/export_import/export_password_dialog.dart';
import 'package:nostr_notes/auth/presentation/tools/share_file_helper.dart';
import 'package:nostr_notes/l10n/localization.dart';
import 'package:common/app/theme/sizes.dart';
import 'package:nostr_notes/auth/presentation/model/path_params.dart';
import 'package:nostr_notes/auth/presentation/tools/note_decrypt_error_message_mixin.dart';
import 'package:nostr_notes/auth/presentation/note_preview_screen/bloc/note_preview_bloc.dart';
import 'package:nostr_notes/auth/presentation/note_preview_screen/bloc/note_preview_state.dart';
import 'package:common/presentation/buttons/refresh_button/refresh_button.dart';

import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/common/presentation/layout/app_platform.dart';
import 'bloc/note_preview_event.dart';
import 'widgets/note_preview_search_vm.dart';
import 'widgets/note_preview_search_widgets.dart';

part 'note_preview_screen_share_part.dart';

abstract interface class NotePreviewScreenCoordinator {
  FutureOr<dynamic> onNoteDetailsRoute(
    BuildContext context, {
    required String noteId,
  });

  FutureOr<dynamic> onRawEventRoute(
    BuildContext context, {
    required String eventId,
  });
}

final class NotePreviewScreen extends StatefulWidget {
  final PathParams pathParams;
  final NotePreviewScreenCoordinator coordinator;

  const NotePreviewScreen({
    super.key,
    required this.pathParams,
    required this.coordinator,
  });

  @override
  State<NotePreviewScreen> createState() => _NotePreviewScreenState();
}

final class _NotePreviewScreenState extends State<NotePreviewScreen>
    with DialogHelper, LabelsPickerHelper, _ExportNoteHelper, ShareFileHelper {
  final vm = SearchVM();

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  void _listener(BuildContext context, NotePreviewState state) async {
    final hud = ProgressHud.of(context);
    hud?.setLoading(isLoading: state is LoadingState);
    switch (state) {
      case CommonState():
      case CannotDecryptState():
        break;
      case LoadingState():
        hud?.vm.progress = state.progress;
        break;
      case ErrorState():
        showError(context, error: state.error);
        break;
      case ExportNoteSuccessState(
        :final filePath,
        :final bytes,
        :final fileName,
      ):
        shareFile(filePath, bytes, fileName, context);
        break;
      case WillExportNoteState():
        onExportNote(context);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProgressHudWidgetContent(
      child: BlocProvider(
        create: (context) => NotePreviewBloc(pathParams: widget.pathParams),
        child: BlocConsumer<NotePreviewBloc, NotePreviewState>(
          listener: _listener,
          builder: (context, state) {
            final note = state.data.note.value;

            return ValueListenableBuilder(
              valueListenable: vm.searchQuery,
              builder: (context, _, _) {
                final content = note?.content ?? '';
                final mediaPaddings = MediaQuery.paddingOf(context);
                final matches = vm.getMatches(content);
                final matchCount = matches.length;
                final isEnabled = note != null && state is! CannotDecryptState;

                return Scaffold(
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
                      ValueListenableBuilder(
                        valueListenable: vm.isSearchVisible,
                        builder: (context, value, _) {
                          return _SearchButton(
                            active: value,
                            onPressed: vm.toggleSearch,
                          );
                        },
                      ),
                      _MoreButton(
                        onAssignFolder: isEnabled
                            ? () => _onAssignFolder(context, note)
                            : null,
                        onCopyContent: isEnabled
                            ? () => _onCopyContent(note.content)
                            : null,
                        onInfo: isEnabled
                            ? () => _onInfo(context, note.eventId)
                            : null,
                        onExportNote: isEnabled
                            ? () => willExportNote(context)
                            : null,
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
                    child: Column(
                      children: [
                        ListenableBuilder(
                          listenable: vm.searchStateListenable,
                          builder: (context, _) {
                            return AnimatedSize(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOut,
                              child: vm.isVisible
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: Sizes.indent,
                                      ),
                                      child: NotePreviewSearchBar(
                                        controller: vm.searchController,
                                        matchCount: matchCount,
                                        currentIndex:
                                            vm.currentMatchIndex.value,
                                        queryNotEmpty: vm.isSearchNotEmpty,
                                        onChanged: vm.onSearchChanged,
                                        onNext: () =>
                                            vm.nextMatch(content, matchCount),
                                        onPrev: () =>
                                            vm.prevMatch(content, matchCount),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            );
                          },
                        ),
                        Expanded(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints.expand(),
                            child: state is CannotDecryptState
                                ? _CannotDecryptPlaceholder(error: note?.error)
                                : RefreshIndicator.adaptive(
                                    onRefresh: () async => _onRefresh(context),
                                    child: SingleChildScrollView(
                                      controller: vm.scrollController,
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      padding: EdgeInsets.only(
                                        left: Sizes.indent2x,
                                        right: Sizes.indent2x,
                                        bottom:
                                            mediaPaddings.bottom +
                                            kFloatingActionButtonMargin +
                                            Sizes.fabSize,
                                      ),
                                      child: ListenableBuilder(
                                        listenable: vm.searchStateListenable,
                                        builder: (context, snapshot) {
                                          final isSearchActive =
                                              vm.isSearchVisible.value &&
                                              vm.isSearchNotEmpty;

                                          return AnimatedCrossFade(
                                            duration: AppDurations.medium,
                                            crossFadeState: isSearchActive
                                                ? CrossFadeState.showSecond
                                                : CrossFadeState.showFirst,
                                            firstChild: SelectionArea(
                                              child:
                                                  GptMarkdownWidget.withCodeBuilders(
                                                    md: content,
                                                  ),
                                            ),
                                            secondChild:
                                                NotePreviewSearchableText(
                                                  text: content,
                                                  matches: matches,
                                                  currentMatchIndex: vm
                                                      .currentMatchIndex
                                                      .value,
                                                ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _onEdit(BuildContext context, String noteId) {
    widget.coordinator.onNoteDetailsRoute(context, noteId: noteId);
  }

  Future _onRefresh(BuildContext context) async {
    context.read<NotePreviewBloc>().add(const NotePreviewEvent.refresh());
    await Future.delayed(Durations.extralong1);
  }

  void _onInfo(BuildContext context, String eventId) {
    widget.coordinator.onRawEventRoute(context, eventId: eventId);
  }

  void _onAssignFolder(BuildContext context, Note note) {
    showLabelsPicker(
      context,
      note: note,
      onApply: (labels) => _onApplyLabels(context, note, labels),
    );
  }

  void _onApplyLabels(
    BuildContext context,
    Note note,
    List<CategoryType> labels,
  ) {
    context.read<NotePreviewBloc>().add(
      NotePreviewEvent.assignLabels(note: note, labels: labels),
    );
  }

  void _onCopyContent(String content) {
    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.commonL10n.commonCopied)));
  }
}

final class _SearchButton extends StatelessWidget {
  final bool active;
  final VoidCallback onPressed;

  const _SearchButton({required this.active, required this.onPressed});

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
        active ? Icons.search_off_rounded : Icons.search_rounded,
        size: Sizes.iconMedium,
        color: active
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurfaceVariant,
      ),
    );
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

final class _MoreButton extends StatelessWidget {
  final VoidCallback? onAssignFolder;
  final VoidCallback? onCopyContent;
  final VoidCallback? onInfo;
  final VoidCallback? onExportNote;

  const _MoreButton({
    this.onAssignFolder,
    this.onCopyContent,
    this.onInfo,
    this.onExportNote,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final isEnabled =
        onAssignFolder != null ||
        onCopyContent != null ||
        onInfo != null ||
        onExportNote != null;
    return CommonPopupMenuButton(
      size: const Size(40, 40),
      icon: Center(
        child: Icon(
          Icons.more_horiz_rounded,
          size: Sizes.iconMedium,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      onSelected: (p0) async {
        p0.payload?.call();
      },
      offset: const Offset(0.0, 40.0),
      items: [
        CommonPopupMenuItem(
          title: _MenuItem(
            title: l10n.notePreviewMoreMenuAssignFolder,
            icon: Icons.label_outline,
          ),
          payload: isEnabled ? onAssignFolder : null,
        ),
        CommonPopupMenuItem(
          title: _MenuItem(
            title: l10n.notePreviewMoreMenuCopyContent,
            icon: Icons.copy_outlined,
          ),
          payload: isEnabled ? onCopyContent : null,
        ),
        CommonPopupMenuItem(
          title: _MenuItem(
            title: l10n.notePreviewMoreMenuInfo,
            icon: Icons.info_outline,
          ),
          payload: isEnabled ? onInfo : null,
        ),
        CommonPopupMenuItem(
          title: _MenuItem(
            title: l10n.notePreviewMoreMenuExportNote,
            icon: Icons.upload_outlined,
          ),
          payload: isEnabled ? onExportNote : null,
        ),
      ],
    );
  }
}

final class _MenuItem extends StatelessWidget {
  final String title;
  final IconData icon;

  const _MenuItem({required this.title, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Sizes.indentVariant2x),
      child: Row(
        spacing: Sizes.indent,
        children: [
          Icon(icon, size: Sizes.iconSmall),
          Text(title),
        ],
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
