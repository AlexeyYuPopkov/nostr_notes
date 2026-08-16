import 'dart:async';

import 'package:custom_adaptive_scaffold/custom_adaptive_scaffold.dart' as asc;
import 'package:di_storage/di_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nostr_notes/app/icons/app_icons.dart';
import 'package:nostr_notes/app/router/app_route/route_handler.dart';
import 'package:nostr_notes/app/router/drawer_router.dart' show DrawerRouter;
import 'package:nostr_notes/app/router/screens_assembly/screens_assembly.dart';
import 'package:common/app/theme/sizes.dart';
import 'package:nostr_notes/auth/domain/usecase/desktop_ratio_usecase.dart';
import 'package:nostr_notes/auth/presentation/account_switcher/account_switcher_panel.dart';
import 'package:nostr_notes/auth/presentation/home_screen/fab.dart';
import 'package:nostr_notes/auth/presentation/home_screen/left_drawer.dart';
import 'package:nostr_notes/auth/presentation/home_screen/widgets/resize_divider.dart';
import 'package:nostr_notes/common/presentation/layout/layout_config.dart';
import 'package:rxdart/rxdart.dart';

import '../dashboard/notes_list.dart';

abstract interface class HomeScreenCoordinator implements NotesListCoordinator {
  const HomeScreenCoordinator();
}

final class HomeScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final GlobalKey<LeftDrawerState> leftDrawerKey;
  final ScreensAssembly screensAssembly;
  final HomeScreenCoordinator coordinator;
  final Widget child;
  final bool hasNote;
  final String? selectedNoteDTag;

  const HomeScreen({
    super.key,
    required this.scaffoldKey,
    required this.leftDrawerKey,
    required this.screensAssembly,
    required this.coordinator,
    required this.child,
    required this.hasNote,
    this.selectedNoteDTag,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

final class _DesktopRatioVM {
  StreamSubscription? _subscription;
  late final _bodyRatio = BehaviorSubject<double>.seeded(
    LayoutConfig.getRatio(_ratioUsecase.get()),
  );

  late final _ratioUsecase = DesktopRatioUsecase(
    repo: DiStorage.shared.resolve(),
    sessionUsecase: DiStorage.shared.resolve(),
  );

  _DesktopRatioVM() {
    _subscription = _bodyRatio.debounceTime(AppDurations.long).listen((_) {
      _ratioUsecase.set(_bodyRatio.value);
    });
  }

  void dispose() {
    _ratioUsecase.set(_bodyRatio.value);
    _subscription?.cancel();
    _bodyRatio.close();
  }

  void onRatioChange(double delta, double screenWidth) {
    final newRatio = (_bodyRatio.value + delta / screenWidth).clamp(
      LayoutConfig.minBodyRatio,
      LayoutConfig.maxBodyRatio,
    );
    if (newRatio != _bodyRatio.value) {
      _bodyRatio.value = newRatio;
    }
  }
}

final class _HomeScreenState extends State<HomeScreen> {
  late final _ratioVM = _DesktopRatioVM();

  @override
  void dispose() {
    _ratioVM.dispose();
    super.dispose();
  }

  void _onResizeDividerDrag(double delta, double screenWidth) {
    _ratioVM.onRatioChange(delta, screenWidth);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= LayoutConfig.desktopScreenWidth;
    final drawerWidth = screenWidth * LayoutConfig.drawerRatio;
    final switcherWidth = screenWidth * LayoutConfig.switcherDrawerRatio;

    // log(drawerWidth.toString(), name: 'HomeScreen.build');

    return LeftDrawer(
      key: widget.leftDrawerKey,
      drawerWidth: isDesktop ? switcherWidth : screenWidth,
      drawer: AccountSwitcherPanel(
        onAddAccount: () {
          widget.leftDrawerKey.currentState?.close();
          widget.coordinator.onAddAccountRoute(context);
        },
      ),
      content: Scaffold(
        key: widget.scaffoldKey,
        endDrawer: SizedBox(
          width: isDesktop ? drawerWidth : double.infinity,
          child: DrawerRouter(screensAssembly: widget.screensAssembly),
        ),
        body: RouteHandlerWidget(
          onRoute: (route, ctx) =>
              RouteHandler.of(context)?.onRoute(route, ctx),
          child: _buildAdaptiveLayout(context, screenWidth),
        ),
      ),
    );
  }

  Widget _buildAdaptiveLayout(BuildContext context, double screenWidth) {
    asc.SlotLayoutConfig bodyConfig() => asc.SlotLayout.from(
      key: const Key('Body Desktop'),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.only(left: Sizes.indent),
          child: Row(
            children: [
              Expanded(
                child: _NoteList(
                  selectedNoteDTag: widget.selectedNoteDTag,
                  coordinator: widget.coordinator,
                ),
              ),
              ResizeDivider(
                onDrag: (delta) => _onResizeDividerDrag(delta, screenWidth),
              ),
            ],
          ),
        );
      },
    );

    asc.SlotLayoutConfig secondaryConfig() => asc.SlotLayout.from(
      key: const Key('SecondaryBody Desktop'),
      builder: (_) => Scaffold(
        body: widget.child,
        floatingActionButton: Fab(
          onNewNote: () => widget.coordinator.onNewNoteRoute(context),
        ),
      ),
    );

    asc.SlotLayoutConfig smallConfig() => asc.SlotLayout.from(
      key: const Key('Body Small'),
      builder: (_) => _MobileLayout(
        hasNote: widget.hasNote,
        selectedNoteDTag: widget.selectedNoteDTag,
        coordinator: widget.coordinator,
        child: widget.child,
      ),
    );

    return StreamBuilder(
      stream: _ratioVM._bodyRatio,
      initialData: _ratioVM._bodyRatio.value,
      builder: (context, snapshot) {
        final value = snapshot.data!;
        return asc.AdaptiveLayout(
          bodyRatio: value,
          bodyOrientation: Axis.horizontal,
          internalAnimations: LayoutConfig.internalAnimations,
          body: asc.SlotLayout(
            config: {
              asc.Breakpoints.small: smallConfig(),
              asc.Breakpoints.medium: bodyConfig(),
              asc.Breakpoints.mediumLarge: bodyConfig(),
              asc.Breakpoints.large: bodyConfig(),
              asc.Breakpoints.extraLarge: bodyConfig(),
            },
          ),
          secondaryBody: asc.SlotLayout(
            config: {
              asc.Breakpoints.medium: secondaryConfig(),
              asc.Breakpoints.mediumLarge: secondaryConfig(),
              asc.Breakpoints.large: secondaryConfig(),
              asc.Breakpoints.extraLarge: secondaryConfig(),
            },
          ),
        );
      },
    );
  }
}

final class _MobileLayout extends StatelessWidget {
  final Widget child;
  final bool hasNote;
  final HomeScreenCoordinator coordinator;
  final String? selectedNoteDTag;
  const _MobileLayout({
    required this.child,
    required this.hasNote,
    required this.coordinator,
    this.selectedNoteDTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _NoteList(
            selectedNoteDTag: selectedNoteDTag,
            coordinator: coordinator,
          ),
          AnimatedSlide(
            offset: hasNote ? const Offset(0.0, 0.0) : const Offset(1.0, 0.0),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: hasNote ? child : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

final class _NoteList extends StatelessWidget {
  final HomeScreenCoordinator coordinator;
  final String? selectedNoteDTag;

  const _NoteList({this.selectedNoteDTag, required this.coordinator});

  @override
  Widget build(BuildContext context) {
    return NotesList(
      selectedNoteDTag: selectedNoteDTag,
      coordinator: coordinator,
    );
  }
}

final class PlaceholderAddNoteButton extends StatelessWidget {
  final VoidCallback? onNewNote;
  const PlaceholderAddNoteButton({super.key, this.onNewNote});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onNewNote,
      child: Stack(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(
                Radius.circular(Sizes.iconTitle / 2.0),
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.2,
                  ),
                  blurRadius: 15,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: SizedBox(
              width: Sizes.iconTitle,
              height: Sizes.iconTitle,
              child: SvgPicture.asset(
                AppIcons.icBg,
                semanticsLabel: 'New Note Icon',
              ),
            ),
          ),
          Positioned.fill(
            child: Icon(
              Icons.edit_outlined,
              size: Sizes.iconTitle / 2,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
