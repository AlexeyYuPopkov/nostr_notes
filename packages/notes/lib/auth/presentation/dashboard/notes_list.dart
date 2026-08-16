import 'dart:async';

import 'package:common/presentation/buttons/refresh_button/refresh_button.dart';
import 'package:common/presentation/dialogs/dialog_helper.dart';
import 'package:common/presentation/tools/section_scroll_vm.dart';
import 'package:di_storage/di_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/auth/domain/model/label.dart';
import 'package:nostr_notes/auth/domain/model/login_item.dart';
import 'package:nostr_notes/auth/presentation/account_switcher/account_switcher_panel.dart';
import 'package:nostr_notes/common/presentation/account_avatar.dart';
import 'package:nostr_notes/auth/presentation/dashboard/notes_list_tab.dart';
import 'package:nostr_notes/common/domain/usecase/get_user_usecase.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';
import 'package:nostr_notes/unauth/presentation/acc_switcher/account_chip_vm.dart';
import 'package:nostr_notes/l10n/localization.dart';
import 'package:common/app/theme/sizes.dart';
import 'package:nostr_notes/common/presentation/layout/app_platform.dart';
import 'package:nostr_notes/common/presentation/layout/breakpoints.dart';
import 'package:nostr_notes/auth/presentation/home_screen/fab.dart';

import 'accs/bloc/accs_bloc.dart';
import 'bloc/dashboard_bloc.dart';
import 'bloc/dashboard_state.dart' as dashboard_state;
import 'notes/bloc/notes_list_bloc.dart';
import 'notes/bloc/notes_list_event.dart';
import 'notes/bloc/notes_list_state.dart';
import 'decrypt_failed_dialog_mixin.dart';
import 'header/note_list_header.dart';
import 'widgets/relay_status_indicator.dart';

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

  void onAddLoginItemRoute(BuildContext context);

  void onLoginItemDetails(
    BuildContext context, {
    required LoginItem item,
    required bool readonly,
  });
}

final class NotesList extends StatelessWidget {
  final String? selectedNoteDTag;

  final NotesListCoordinator coordinator;
  const NotesList({
    super.key,
    this.selectedNoteDTag,
    required this.coordinator,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => DashboardBloc()),
        BlocProvider(
          create: (context) =>
              AccsBloc(dashboardBloc: context.read<DashboardBloc>()),
        ),
        BlocProvider(
          create: (context) => NotesListBloc(
            l10n: l10n,
            dashboardBloc: context.read<DashboardBloc>(),
          ),
        ),
      ],
      child: Builder(
        builder: (context) {
          return _Dashboard(
            selectedNoteDTag: selectedNoteDTag,
            coordinator: coordinator,
          );
        },
      ),
    );
  }
}

final class _Dashboard extends StatefulWidget {
  final String? selectedNoteDTag;

  final NotesListCoordinator coordinator;
  const _Dashboard({required this.selectedNoteDTag, required this.coordinator});

  @override
  State<_Dashboard> createState() => _DashboardState();
}

final class _DashboardState extends State<_Dashboard>
    with DialogHelper, DecryptFailedDialogMixin {
  final _nestedScrollKey = GlobalKey<NestedScrollViewState>();

  StreamSubscription? _decryptFailureSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final innerScrollController =
          _nestedScrollKey.currentState?.innerController;
      if (innerScrollController != null) {
        context.read<NotesListBloc>().sectionScrollVm.setInnerScrollController(
          innerScrollController,
        );
        context.read<AccsBloc>().sectionScrollVm.setInnerScrollController(
          innerScrollController,
        );
      }
    });

    // Shared across tabs: whichever tab detects a wrong-PIN decrypt failure
    // first, DashboardBloc gates the dialog to once per screen instance.
    _decryptFailureSubscription = context
        .read<DashboardBloc>()
        .decryptFailures
        .listen((report) {
          if (!mounted) return;
          showDecryptFailedDialog(
            context,
            failedCount: report.failedCount,
            totalCount: report.totalCount,
          );
        });
  }

  @override
  void dispose() {
    _decryptFailureSubscription?.cancel();
    super.dispose();
  }

  bool _onScrollNotification(ScrollNotification notification) =>
      context.read<DashboardBloc>().headerVm.onScrollNotification(notification);

  void _listener(BuildContext context, NotesListState state) {
    switch (state) {
      case CommonState():
      case LoadingState():
        break;
      case ErrorState():
        final e = state.e;
        if (e is SomeNotesWasNotDecrypted) {
          break;
        }
        showError(context, error: e);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final breakpoint = Breakpoint.activeBreakpointOf(context);
    final theme = Theme.of(context);

    return BlocConsumer<NotesListBloc, NotesListState>(
      listener: _listener,
      builder: (context, state) {
        final bloc = context.read<NotesListBloc>();
        final vm = bloc.sectionScrollVm;
        final dashboardBloc = context.read<DashboardBloc>();

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
                title: ValueListenableBuilder(
                  valueListenable: vm.currentItemNotifier,
                  builder: (context, value, child) {
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
                      crossFadeState: value == null
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                    );
                  },
                ),
                actions: [
                  if (const AppPlatform().isDesktopLayout)
                    RefreshButton(
                      vm: dashboardBloc.refreshButtonVm,
                      padding: const EdgeInsets.only(left: Sizes.indent2x),
                      alignment: Alignment.centerRight,
                    ),
                  const RelayStatusIndicator(),
                  _SettingsButton(onEndDrawer: widget.coordinator.onEndDrawer),
                ],
              ),
              floatingActionButton: breakpoint.isSmall
                  ? Fab(onNewNote: () => _onFab(context))
                  : null,
              body: Stack(
                children: [
                  NotificationListener<ScrollNotification>(
                    onNotification: _onScrollNotification,
                    child: NestedScrollView(
                      key: _nestedScrollKey,
                      controller: dashboardBloc.headerVm.scrollController,
                      headerSliverBuilder: (context, _) => const <Widget>[],
                      body:
                          BlocListener<
                            DashboardBloc,
                            dashboard_state.DashboardState
                          >(
                            listenWhen: (a, b) => a.data.tab != b.data.tab,
                            listener: (context, state) {
                              dashboardBloc.headerVm.headerVisibility.value =
                                  1.0;
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
                                      coordinator: widget.coordinator,
                                      scrollSectionsVm: vm,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                    ),
                  ),
                  _Header(headerVm: dashboardBloc.headerVm, scrollVm: vm),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _onFab(BuildContext context) {
    final currentTab = context.read<DashboardBloc>().state.data.tab;

    switch (currentTab) {
      case NotesNotesTab():
        widget.coordinator.onNewNoteRoute(context);
      case AccsTab():
        widget.coordinator.onAddLoginItemRoute(context);
    }
  }
}

final class _Header extends StatelessWidget {
  final SectionScrollVm scrollVm;
  final NoteListHeaderVm headerVm;
  const _Header({required this.scrollVm, required this.headerVm});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      DashboardBloc,
      dashboard_state.DashboardState,
      NotesListTab
    >(
      selector: (state) => state.data.tab,
      builder: (context, tab) {
        final searchString = switch (tab) {
          NotesNotesTab() =>
            context.read<NotesListBloc>().state.data.searchString,
          AccsTab() => context.read<AccsBloc>().state.data.searchString,
        };
        return BlocSelector<NotesListBloc, NotesListState, Set<CategoryType>>(
          selector: (state) => state.data.folderFilter,
          builder: (context, filters) {
            return NoteListHeader(
              vm: headerVm,
              scrollVm: scrollVm,
              tab: tab,
              searchString: searchString,
              filters: filters,
              onRemoveFilter: (e) => _onRemoveFilter(context, e),
            );
          },
        );
      },
    );
  }

  void _onRemoveFilter(BuildContext context, CategoryType folder) {
    context.read<NotesListBloc>().add(
      NotesListEvent.setFolderFilter(
        {...context.read<NotesListBloc>().state.data.folderFilter}
          ..remove(folder),
      ),
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
          Icons.menu_outlined,
          size: Sizes.iconMedium,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

final class _AccountSwitcherButton extends StatefulWidget {
  final VoidCallback onOpenSwitcher;
  final VoidCallback onAddAccount;
  const _AccountSwitcherButton({
    required this.onOpenSwitcher,
    required this.onAddAccount,
  });

  @override
  State<_AccountSwitcherButton> createState() => _AccountSwitcherButtonState();
}

final class _AccountSwitcherButtonState extends State<_AccountSwitcherButton> {
  late final _pubkey = DiStorage.shared
      .resolve<SessionUsecase>()
      .currentSession
      .pubkey;
  late final _vm = AccountChipVM(
    pubkey: _pubkey,
    getUserUsecase: DiStorage.shared.resolve<GetUserUsecase>(),
  );

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final breakpoint = Breakpoint.activeBreakpointOf(context);

    return Tooltip(
      message: context.l10n.accountSwitcherTitle,
      child: CupertinoButton(
        minimumSize: Size.zero,
        padding: EdgeInsets.zero,
        onPressed: () {
          if (breakpoint.isSmall) {
            showModalBottomSheet(
              context: context,
              showDragHandle: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              builder: (sheetContext) => AccountSwitcherPanel(
                onAddAccount: () {
                  Navigator.of(sheetContext).pop();
                  widget.onAddAccount();
                },
              ),
            );
          } else {
            widget.onOpenSwitcher();
          }
        },
        child: ListenableBuilder(
          listenable: _vm,
          builder: (context, _) {
            return AccountAvatar(
              pubkey: _pubkey,
              size: Sizes.icon,
              pictureUrl: _vm.user?.picture,
            );
          },
        ),
      ),
    );
  }
}
