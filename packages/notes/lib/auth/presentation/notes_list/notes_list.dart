import 'package:common/app/icons/app_icons.dart';
import 'package:common/presentation/buttons/refresh_button/refresh_button.dart';
import 'package:common/presentation/tools/section_scroll_vm.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nostr_notes/auth/presentation/notes_list/tabs/notes_list_tab.dart';
import 'package:nostr_notes/common/presentation/formatters/date_group.dart';
import 'package:nostr_notes/l10n/localization.dart';
import 'package:nostr_notes/app/router/app_route/route_handler.dart';
import 'package:nostr_notes/app/router/drawer_router.dart';
import 'package:common/app/theme/sizes.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/common/presentation/layout/app_platform.dart';
import 'package:nostr_notes/common/presentation/layout/breakpoints.dart';
import 'package:nostr_notes/auth/presentation/home_screen/fab.dart';

import 'package:common/presentation/dialogs/dialog_helper.dart';

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

class _NotesListState extends State<NotesList> with DialogHelper {
  final _nestedScrollKey = GlobalKey<NestedScrollViewState>();
  final scrollController = ScrollController();
  late final _vm = SectionScrollVm<NotesListHeader>(
    scrollController: scrollController,
  );

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
    super.dispose();
  }

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
    final breakpoint = Breakpoint.activeBreakpointOf(context);
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return BlocProvider(
      create: (context) => NotesListBloc(l10n: l10n),
      child: BlocConsumer<NotesListBloc, NotesListState>(
        listener: _listener,
        builder: (context, state) {
          final foldersVm = context.read<NotesListBloc>().foldersVm;
          return DefaultTabController(
            length: NotesListTab.tabs.length,
            child: Scaffold(
              floatingActionButton: breakpoint.isSmall ? const Fab() : null,
              body: NestedScrollView(
                key: _nestedScrollKey,
                controller: scrollController,
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  SliverAppBar(
                    pinned: true,
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
                              firstChild: Text(
                                context.l10n.notesListScreenTitle,
                              ),
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
                  SliverToBoxAdapter(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: HelphubScreenToolbar(),
                    ),
                  ),
                ],
                body: BlocListener<NotesListBloc, NotesListState>(
                  listenWhen: (a, b) => a.data.tab != b.data.tab,
                  listener: (context, state) => DefaultTabController.of(
                    context,
                  ).animateTo(NotesListTab.tabs.indexOf(state.data.tab)),
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
          );
        },
      ),
    );
  }
}

final class HelphubScreenToolbar extends StatelessWidget {
  const HelphubScreenToolbar({super.key});

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
    return CupertinoButton(
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
    );
  }

  void _onNewNote(BuildContext context) {
    RouteHandler.of(context)?.onRoute(const OnEndDrawer(), context);
  }
}
