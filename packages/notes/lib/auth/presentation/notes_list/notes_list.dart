import 'package:common/app/icons/app_icons.dart';
import 'package:common/presentation/buttons/refresh_button/refresh_button.dart';
import 'package:common/presentation/dialogs/dialog_helper.dart';
import 'package:common/presentation/tools/section_scroll_vm.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nostr_notes/auth/domain/model/label.dart';
import 'package:nostr_notes/auth/presentation/model/category_localization.dart';
import 'package:nostr_notes/auth/presentation/notes_list/tabs/notes_list_tab.dart';
import 'package:nostr_notes/auth/presentation/notes_list/widgets/notes_search_field.dart';
import 'package:nostr_notes/common/presentation/formatters/date_group.dart';
import 'package:nostr_notes/l10n/localization.dart';
import 'package:nostr_notes/app/router/app_route/route_handler.dart';
import 'package:nostr_notes/app/router/drawer_router.dart';
import 'package:common/app/theme/sizes.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/common/presentation/layout/app_platform.dart';
import 'package:nostr_notes/common/presentation/layout/breakpoints.dart';
import 'package:nostr_notes/auth/presentation/home_screen/fab.dart';

import 'bloc/notes_list_bloc.dart';
import 'bloc/notes_list_event.dart';
import 'bloc/notes_list_state.dart';
import 'widgets/common_toolbar_tabs_widget.dart';

final class NotesList extends StatefulWidget {
  final String? selectedNoteDTag;
  final ValueChanged<Note> onTap;
  const NotesList({
    super.key,
    required this.selectedNoteDTag,
    required this.onTap,
  });

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
                    const _SettingsButton(),
                  ],
                ),
                floatingActionButton: breakpoint.isSmall ? const Fab() : null,
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
                                    onTap: widget.onTap,
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
        color: Theme.of(context).colorScheme.surface,
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
  const _SettingsButton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: context.l10n.settingsScreenTitle,
      child: CupertinoButton(
        child: SvgPicture.asset(
          CommonIcons.profileIcon,
          width: Sizes.icon,
          height: Sizes.icon,
          colorFilter: ColorFilter.mode(
            theme.colorScheme.onSurfaceVariant,
            BlendMode.srcIn,
          ),
        ),
        onPressed: () => _onNewNote(context),
      ),
    );
  }

  void _onNewNote(BuildContext context) {
    RouteHandler.of(context)?.onRoute(const OnEndDrawer(), context);
  }
}
