import 'dart:async';

import 'package:common/presentation/buttons/refresh_button/refresh_button.dart';
import 'package:common/presentation/dialogs/dialog_helper.dart';
import 'package:common/presentation/tools/section_scroll_vm.dart';
import 'package:di_storage/di_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/auth/domain/model/label.dart';
import 'package:nostr_notes/auth/presentation/account_switcher/account_switcher_panel.dart';
import 'package:nostr_notes/auth/presentation/model/category_localization.dart';
import 'package:nostr_notes/auth/presentation/notes_list/tabs/notes_list_tab.dart';
import 'package:nostr_notes/auth/presentation/notes_list/widgets/notes_search_field.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';
import 'package:nostr_notes/common/presentation/formatters/date_group.dart';
import 'package:nostr_notes/l10n/localization.dart';
import 'package:common/app/theme/sizes.dart';
import 'package:nostr_notes/common/presentation/layout/app_platform.dart';
import 'package:nostr_notes/common/presentation/layout/breakpoints.dart';
import 'package:nostr_notes/auth/presentation/home_screen/fab.dart';

import 'bloc/notes_list_bloc.dart';
import 'bloc/notes_list_event.dart';
import 'bloc/notes_list_state.dart';
import 'widgets/common_toolbar_tabs_widget.dart';

abstract interface class NotesListCoordinator {
  const NotesListCoordinator();

  FutureOr<dynamic> onNotePreviewRoute(
    BuildContext context, {
    required String noteId,
  });

  void onNewNoteRoute(BuildContext context);

  void onEndDrawer();

  void onAccountSwitcher();

  void onAddAccountRoute(BuildContext context);
}

final class NotesList extends StatefulWidget {
  final String? selectedNoteDTag;

  final NotesListCoordinator coordinator;
  const NotesList({
    super.key,
    required this.selectedNoteDTag,
    required this.coordinator,
  });

  //   onTap: (note) =>
  //     coordinator.onNotePreviewRoute(context, noteId: note.dTag),
  // onNewNote: () => coordinator.onNewNoteRoute(context),
  // onEndDrawer: () => coordinator.onEndDrawer(),
  // onAccountSwitcher: () => coordinator.onAccountSwitcher(),

  @override
  State<NotesList> createState() => _NotesListState();
}

final class _NotesListState extends State<NotesList> with DialogHelper {
  final _nestedScrollKey = GlobalKey<NestedScrollViewState>();
  final scrollController = ScrollController();
  late final _vm = SectionScrollVm<NotesListHeader>(
    scrollController: scrollController,
  );

  final _headerVisible = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final innerScrollController =
          _nestedScrollKey.currentState?.innerController;
      if (innerScrollController != null) {
        _vm.setInnerScrollController(innerScrollController);
      }
    });
  }

  @override
  void dispose() {
    _vm.dispose();
    scrollController.dispose();
    _headerVisible.dispose();
    super.dispose();
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      final metrics = notification.metrics;
      if (metrics.pixels <= metrics.minScrollExtent) {
        _headerVisible.value = true;
        return false;
      }
    }

    if (notification is UserScrollNotification &&
        !notification.metrics.outOfRange) {
      switch (notification.direction) {
        case ScrollDirection.reverse:
          _headerVisible.value = false;
        case ScrollDirection.forward:
          _headerVisible.value = true;
        case ScrollDirection.idle:
          break;
      }
    }
    return false;
  }

  void _listener(BuildContext context, NotesListState state) {
    switch (state) {
      case CommonState():
      case LoadingState():
        break;
      case ErrorState():
        showError(
          context,
          error: state.e,
          messageBuilder: (error) {
            if (error is SomeNotesWasNotDecrypted) {
              return context.l10n.notesListSomeNotesDecryptFailed;
            }
            return null;
          },
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final breakpoint = Breakpoint.activeBreakpointOf(context);
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return BlocProvider(
      create: (context) => NotesListBloc(l10n: l10n),
      child: BlocConsumer<NotesListBloc, NotesListState>(
        listener: _listener,
        builder: (context, state) {
          final foldersVm = context.read<NotesListBloc>().foldersVm;
          return AbsorbPointer(
            absorbing: state is LoadingState,
            child: DefaultTabController(
              length: NotesListTab.tabs.length,
              child: Scaffold(
                appBar: AppBar(
                  leading: _AccountSwitcherButton(
                    onOpenSwitcher: widget.coordinator.onAccountSwitcher,
                    onAddAccount: () =>
                        widget.coordinator.onAddAccountRoute(context),
                  ),
                  title: ListenableBuilder(
                    listenable: foldersVm,
                    builder: (context, _) {
                      return ValueListenableBuilder(
                        valueListenable: _vm.currentItemNotifier,
                        builder: (context, value, child) {
                          final needsTitle =
                              state.data.tab is FoldersTab &&
                              foldersVm.folder == null;
                          return AnimatedCrossFade(
                            duration: const Duration(milliseconds: 200),
                            firstChild: Text(context.l10n.notesListScreenTitle),
                            secondChild: Align(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                value?.title ?? '',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            crossFadeState: value == null || needsTitle
                                ? CrossFadeState.showFirst
                                : CrossFadeState.showSecond,
                          );
                        },
                      );
                    },
                  ),
                  actions: [
                    if (const AppPlatform().isDesktopLayout)
                      RefreshButton(
                        vm: context.read<NotesListBloc>().refreshButtonVm,
                        padding: const EdgeInsets.only(left: Sizes.indent2x),
                        alignment: Alignment.centerRight,
                      ),
                    _SettingsButton(
                      onEndDrawer: widget.coordinator.onEndDrawer,
                    ),
                  ],
                ),
                floatingActionButton: breakpoint.isSmall
                    ? Fab(
                        onNewNote: () =>
                            widget.coordinator.onNewNoteRoute(context),
                      )
                    : null,
                body: Stack(
                  children: [
                    NotificationListener<ScrollNotification>(
                      onNotification: _onScrollNotification,
                      child: NestedScrollView(
                        key: _nestedScrollKey,
                        controller: scrollController,
                        headerSliverBuilder: (context, _) => const <Widget>[],
                        body: BlocListener<NotesListBloc, NotesListState>(
                          listenWhen: (a, b) => a.data.tab != b.data.tab,
                          listener: (context, state) {
                            _headerVisible.value = true;
                            DefaultTabController.of(context).animateTo(
                              NotesListTab.tabs.indexOf(state.data.tab),
                            );
                          },
                          child: TabBarView(
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              for (final tab in NotesListTab.tabs)
                                tab.build(
                                  context,
                                  params: TabParams(
                                    selectedNoteDTag: widget.selectedNoteDTag,
                                    onTap: (note) =>
                                        widget.coordinator.onNotePreviewRoute(
                                          noteId: note.dTag,
                                          context,
                                        ),
                                    scrollSectionsVm: _vm,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    _Header(visible: _headerVisible, scrollVm: _vm),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

final class _Header extends StatelessWidget {
  final ValueListenable<bool> visible;
  final SectionScrollVm scrollVm;
  const _Header({required this.visible, required this.scrollVm});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: visible,
      builder: (context, isVisible, child) {
        return AnimatedSlide(
          duration: const Duration(milliseconds: 200),
          offset: isVisible ? Offset.zero : const Offset(0.0, -1.0),
          curve: Curves.easeInOut,
          child: child,
        );
      },
      child: ColoredBox(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(bottom: Sizes.indent),
                child: NotesListScreenToolbar(),
              ),
            ),
            BlocSelector<NotesListBloc, NotesListState, (NotesListTab, String)>(
              selector: (state) {
                return (state.data.tab, state.data.searchString);
              },
              builder: (context, data) {
                final foldersVm = context.read<NotesListBloc>().foldersVm;
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: switch (data.$1) {
                    FoldersTab() => ListenableBuilder(
                      key: const ValueKey('folders'),
                      listenable: foldersVm,
                      builder: (context, _) {
                        final folder = foldersVm.folder;
                        if (folder == null) return const SizedBox.shrink();
                        return _FolderBackButton(
                          folder: folder,
                          onBack: () {
                            scrollVm.clearSections();
                            foldersVm.setFolder(null, context.l10n);
                          },
                        );
                      },
                    ),
                    AllNotesTab() => Padding(
                      key: const ValueKey('search'),
                      padding: const EdgeInsets.only(
                        left: Sizes.indent,
                        right: Sizes.indent,
                        bottom: Sizes.indent,
                      ),
                      child: NotesSearchField(initialQuery: data.$2),
                    ),
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

final class _FolderBackButton extends StatelessWidget {
  final CategoryType folder;
  final VoidCallback onBack;
  const _FolderBackButton({required this.folder, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CupertinoButton(
      minimumSize: Size.zero,
      padding: const EdgeInsets.only(
        left: Sizes.indent,
        right: Sizes.indent,
        top: Sizes.indentVariant2x,
      ),
      onPressed: onBack,
      child: Row(
        children: [
          Icon(
            Icons.arrow_back_ios,
            size: Sizes.iconSmall,
            color: theme.colorScheme.onSurface,
          ),
          Text(
            folder.getLocalizedName(context),
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

final class NotesListScreenToolbar extends StatelessWidget {
  const NotesListScreenToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<NotesListBloc, NotesListState, NotesListTab>(
      selector: (state) => state.data.tab,
      builder: (context, tab) {
        return CommonToolbarTabsWidget(
          currentTab: tab,
          tabs: NotesListTab.tabs,
          onChangeTab: (context, _, tab) => _onChangeTab(context, tab: tab),
        );
      },
    );
  }

  void _onChangeTab(
    BuildContext context, {
    required CommonToolbarTabsWidgetTab tab,
  }) {
    context.read<NotesListBloc>().add(
      NotesListEvent.selectFolder(tab as NotesListTab),
    );
  }
}

final class _SettingsButton extends StatelessWidget {
  final VoidCallback? onEndDrawer;
  const _SettingsButton({required this.onEndDrawer});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: context.l10n.settingsScreenTitle,
      child: CupertinoButton(
        onPressed: onEndDrawer,
        child: Icon(
          Icons.settings_outlined,
          size: Sizes.iconMedium,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

final class _AccountSwitcherButton extends StatelessWidget {
  final VoidCallback onOpenSwitcher;
  final VoidCallback onAddAccount;
  const _AccountSwitcherButton({
    required this.onOpenSwitcher,
    required this.onAddAccount,
  });

  @override
  Widget build(BuildContext context) {
    final sessionUsecase = DiStorage.shared.resolve<SessionUsecase>();
    final pubkey = sessionUsecase.currentSession.pubkey;
    final breakpoint = Breakpoint.activeBreakpointOf(context);

    return Tooltip(
      message: context.l10n.accountSwitcherTitle,
      child: CupertinoButton(
        onPressed: () {
          if (breakpoint.isSmall) {
            showModalBottomSheet(
              context: context,
              showDragHandle: true,
              builder: (sheetContext) => AccountSwitcherPanel(
                onAddAccount: () {
                  Navigator.of(sheetContext).pop();
                  onAddAccount();
                },
              ),
            );
          } else {
            onOpenSwitcher();
          }
        },
        child: AccountAvatar(pubkey: pubkey, size: Sizes.icon),
      ),
    );
  }
}
