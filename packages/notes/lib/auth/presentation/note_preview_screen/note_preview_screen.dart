import 'package:common/l10n/localization.dart';
import 'package:common/presentation/widgets/common_popup_menu_button.dart';
import 'package:common/presentation/widgets/markdown/gpt_markdown_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/auth/domain/model/label.dart';
import 'package:nostr_notes/auth/presentation/notes_list/widgets/labels_picker.dart';
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
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/common/presentation/layout/app_platform.dart';
import 'bloc/note_preview_event.dart';

typedef _Match = ({int start, int end});

List<_Match> _findMatches(String text, String query) {
  if (query.isEmpty) return const [];
  final lowerText = text.toLowerCase();
  final lowerQuery = query.toLowerCase();
  final matches = <_Match>[];
  int start = 0;
  while (true) {
    final idx = lowerText.indexOf(lowerQuery, start);
    if (idx == -1) break;
    matches.add((start: idx, end: idx + query.length));
    start = idx + query.length;
  }
  return matches;
}

final class SearchVM extends ChangeNotifier {
  final searchController = TextEditingController();
  final scrollController = ScrollController();

  final isSearchVisible = ValueNotifier(false);
  final searchQuery = ValueNotifier('');
  final currentMatchIndex = ValueNotifier(0);

  bool get isVisible => isSearchVisible.value;
  bool get isSearchEmpty => searchQuery.value.isEmpty;
  bool get isSearchNotEmpty => searchQuery.value.isNotEmpty;

  late final Listenable searchStateListenable = Listenable.merge([
    isSearchVisible,
    searchQuery,
    currentMatchIndex,
  ]);

  SearchVM() {
    searchController.addListener(() {
      searchQuery.value = searchController.text;
      currentMatchIndex.value = 0;
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void toggleSearch() {
    final newValue = !isSearchVisible.value;
    isSearchVisible.value = newValue;
    if (!newValue) {
      searchController.clear();
      searchQuery.value = '';
      currentMatchIndex.value = 0;
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    currentMatchIndex.value = 0;
  }

  void nextMatch(String content, int matchCount) {
    if (matchCount == 0) {
      return;
    }
    final next = (currentMatchIndex.value + 1) % matchCount;
    currentMatchIndex.value = next;

    _scrollToMatch(content, next);
  }

  void prevMatch(String content, int matchCount) {
    if (matchCount == 0) {
      return;
    }
    final prev = (currentMatchIndex.value - 1 + matchCount) % matchCount;
    currentMatchIndex.value = prev;
    _scrollToMatch(content, prev);
  }

  void _scrollToMatch(String content, int index) {
    if (content.isEmpty) {
      return;
    }
    final matches = _findMatches(content, searchQuery.value);
    if (index >= matches.length) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) {
        return;
      }
      final maxScroll = scrollController.position.maxScrollExtent;
      if (maxScroll <= 0) {
        return;
      }
      final ratio = matches[index].start / content.length;
      scrollController.animateTo(
        (ratio * maxScroll).clamp(0.0, maxScroll),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  List<({int end, int start})> getMatches(String content) {
    final matches = isSearchVisible.value && searchQuery.value.isNotEmpty
        ? _findMatches(content, searchQuery.value)
        : const <_Match>[];
    return matches;
  }
}

final class NotePreviewScreen extends StatefulWidget {
  final PathParams pathParams;

  const NotePreviewScreen({super.key, required this.pathParams});

  @override
  State<NotePreviewScreen> createState() => _NotePreviewScreenState();
}

final class _NotePreviewScreenState extends State<NotePreviewScreen>
    with DialogHelper, LabelsPickerHelper {
  final vm = SearchVM();

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

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
                                ? _SearchBar(
                                    controller: vm.searchController,
                                    matchCount: matchCount,
                                    currentIndex: vm.currentMatchIndex.value,
                                    queryNotEmpty: vm.isSearchNotEmpty,
                                    onChanged: vm.onSearchChanged,
                                    onNext: () =>
                                        vm.nextMatch(content, matchCount),
                                    onPrev: () =>
                                        vm.prevMatch(content, matchCount),
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
                                            child: GptMarkdownWidget(
                                              md: content,
                                              codeBuilder:
                                                  (
                                                    context,
                                                    name,
                                                    code,
                                                    closed,
                                                  ) {
                                                    return NoteCodeField(
                                                      name: name,
                                                      codes: code,
                                                    );
                                                  },
                                              highlightBuilder:
                                                  (context, code, closed) {
                                                    return ShortNoteCodeField(
                                                      codes: code,
                                                    );
                                                  },
                                            ),
                                          ),
                                          secondChild: _SearchableText(
                                            text: content,
                                            matches: matches,
                                            currentMatchIndex:
                                                vm.currentMatchIndex.value,
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

final class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final int matchCount;
  final int currentIndex;
  final bool queryNotEmpty;
  final ValueChanged<String> onChanged;
  final VoidCallback onNext;
  final VoidCallback onPrev;

  const _SearchBar({
    required this.controller,
    required this.matchCount,
    required this.currentIndex,
    required this.queryNotEmpty,
    required this.onChanged,
    required this.onNext,
    required this.onPrev,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Sizes.indent,
        vertical: Sizes.indent,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => onNext(),
              decoration: InputDecoration(
                hintText: context.commonL10n.commonHintSearch,
                isDense: true,
                prefixIcon: const Icon(Icons.search, size: Sizes.iconSmall),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Sizes.radius),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: Sizes.indent,
                  horizontal: Sizes.indent,
                ),
              ),
            ),
          ),
          const SizedBox(width: Sizes.indent),
          if (queryNotEmpty)
            Text(
              matchCount > 0 ? '${currentIndex + 1} / $matchCount' : '0',
              style: theme.textTheme.bodySmall?.copyWith(
                color: matchCount > 0
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.colorScheme.error,
              ),
            ),
          IconButton(
            onPressed: matchCount > 0 ? onPrev : null,
            icon: const Icon(Icons.keyboard_arrow_up_rounded),
            iconSize: Sizes.iconMedium,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: Sizes.indent4x,
              minHeight: Sizes.indent4x,
            ),
          ),
          IconButton(
            onPressed: matchCount > 0 ? onNext : null,
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            iconSize: Sizes.iconMedium,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: Sizes.indent4x,
              minHeight: Sizes.indent4x,
            ),
          ),
        ],
      ),
    );
  }
}

final class _SearchableText extends StatelessWidget {
  final String text;
  final List<_Match> matches;
  final int currentMatchIndex;

  const _SearchableText({
    required this.text,
    required this.matches,
    required this.currentMatchIndex,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultStyle = theme.textTheme.bodyMedium ?? const TextStyle();

    if (matches.isEmpty) {
      return Text(text, style: defaultStyle);
    }

    final spans = <InlineSpan>[];
    int cursor = 0;

    for (int i = 0; i < matches.length; i++) {
      final match = matches[i];
      if (cursor < match.start) {
        spans.add(
          TextSpan(
            text: text.substring(cursor, match.start),
            style: defaultStyle,
          ),
        );
      }
      final isCurrent = i == currentMatchIndex;
      spans.add(
        TextSpan(
          text: text.substring(match.start, match.end),
          style: defaultStyle.copyWith(
            backgroundColor: isCurrent
                ? Colors.orange.withValues(alpha: 0.7)
                : Colors.yellow.withValues(alpha: 0.5),
            color: Colors.black,
          ),
        ),
      );
      cursor = match.end;
    }

    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor), style: defaultStyle));
    }

    return SelectionArea(child: Text.rich(TextSpan(children: spans)));
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

  const _MoreButton({this.onAssignFolder, this.onCopyContent, this.onInfo});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled =
        onAssignFolder != null || onCopyContent != null || onInfo != null;
    return CommonPopupMenuButton(
      size: Size(40, 40),
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
          title: _MenuItem(title: 'Assign folder', icon: Icons.label_outline),
          payload: isEnabled ? onAssignFolder : null,
        ),
        CommonPopupMenuItem(
          title: _MenuItem(title: 'Copy content', icon: Icons.copy_outlined),
          payload: isEnabled ? onCopyContent : null,
        ),
        CommonPopupMenuItem(
          title: _MenuItem(title: 'Info', icon: Icons.info_outline),
          payload: isEnabled ? onInfo : null,
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
