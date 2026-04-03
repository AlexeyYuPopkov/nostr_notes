import 'package:custom_adaptive_scaffold/custom_adaptive_scaffold.dart' as asc;
import 'package:di_storage/di_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:nostr_notes/app/icons/app_icons.dart';
import 'package:nostr_notes/app/router/app_route/route_handler.dart';
import 'package:nostr_notes/app/router/app_router_path.dart';
import 'package:nostr_notes/app/router/drawer_router.dart' show DrawerRouter;
import 'package:nostr_notes/app/router/note_router.dart';
import 'package:nostr_notes/app/router/screens_assembly/screens_assembly.dart';
import 'package:common/app/theme/sizes.dart';
import 'package:nostr_notes/auth/domain/usecase/desktop_ratio_usecase.dart';
import 'package:nostr_notes/auth/presentation/home_screen/fab.dart';
import 'package:nostr_notes/auth/presentation/home_screen/widgets/resize_divider.dart';
import 'package:nostr_notes/common/presentation/layout/layout_config.dart';

import '../notes_list/notes_list.dart';

final class HomeScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final ScreensAssembly screensAssembly;
  final Widget child;
  final bool hasNote;
  final String? selectedNoteDTag;

  const HomeScreen({
    super.key,
    required this.scaffoldKey,
    required this.screensAssembly,
    required this.child,
    required this.hasNote,
    this.selectedNoteDTag,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

final class _HomeScreenState extends State<HomeScreen> {
  late double _bodyRatio = LayoutConfig.getRatio(_ratioUsecase.get());
  late final _ratioUsecase = DesktopRatioUsecase(
    repo: DiStorage.shared.resolve(),
    sessionUsecase: DiStorage.shared.resolve(),
  );

  @override
  void dispose() {
    _ratioUsecase.set(_bodyRatio);
    super.dispose();
  }

  void _onResizeDividerDrag(double delta, double screenWidth) {
    final newRatio = (_bodyRatio + delta / screenWidth).clamp(
      LayoutConfig.minBodyRatio,
      LayoutConfig.maxBodyRatio,
    );
    if (newRatio != _bodyRatio) {
      setState(() => _bodyRatio = newRatio);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= LayoutConfig.desktopScreenWidth;
    final drawerWidth = screenWidth * LayoutConfig.drawerRatio;

    return Scaffold(
      key: widget.scaffoldKey,
      endDrawer: SizedBox(
        width: isDesktop ? drawerWidth : double.infinity,
        child: DrawerRouter(screensAssembly: widget.screensAssembly),
      ),
      body: RouteHandlerWidget(
        onRoute: (route, ctx) async {
          if (route is NotePreviewRoute) {
            final router = GoRouter.of(ctx);

            final currentUri = Uri.parse(router.state.matchedLocation);
            final uri = Uri(
              pathSegments: [AppRouterName.home, AppRouterPath.notePreview],
            );

            if (currentUri.pathSegments.contains(AppRouterPath.noteDetails)) {
              await Navigator.of(ctx).maybePop();
            }
            if (currentUri.pathSegments.contains(AppRouterPath.notePreview) ||
                currentUri.pathSegments.contains(AppRouterPath.noteDetails)) {
              return router.pushReplacement(
                '/${uri.path}',
                extra: route.toExtra(),
              );
            } else {
              return router.push('/${uri.path}', extra: route.toExtra());
            }
          }
          return RouteHandler.of(context)?.onRoute(route, ctx);
        },
        child: _buildAdaptiveLayout(context, screenWidth),
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
                child: _NoteList(selectedNoteDTag: widget.selectedNoteDTag),
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
      builder: (_) =>
          Scaffold(body: widget.child, floatingActionButton: const Fab()),
    );

    asc.SlotLayoutConfig smallConfig() => asc.SlotLayout.from(
      key: const Key('Body Small'),
      builder: (_) => _MobileLayout(
        hasNote: widget.hasNote,
        selectedNoteDTag: widget.selectedNoteDTag,
        child: widget.child,
      ),
    );

    return asc.AdaptiveLayout(
      bodyRatio: _bodyRatio,
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
  }
}

final class _MobileLayout extends StatelessWidget {
  final Widget child;
  final bool hasNote;
  final String? selectedNoteDTag;
  const _MobileLayout({
    required this.child,
    required this.hasNote,
    this.selectedNoteDTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _NoteList(selectedNoteDTag: selectedNoteDTag),
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
  final String? selectedNoteDTag;
  const _NoteList({this.selectedNoteDTag});

  @override
  Widget build(BuildContext context) {
    return NotesList(
      selectedNoteDTag: selectedNoteDTag,
      onTap: (note) {
        RouteHandler.of(
          context,
        )?.onRoute(NotePreviewRoute(noteId: note.dTag), context);
      },
    );
  }
}

final class PlaceholderAddNoteButton extends StatelessWidget {
  const PlaceholderAddNoteButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => _onNewNote(context),
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

  void _onNewNote(BuildContext context) {
    RouteHandler.of(context)?.onRoute(const NewNoteRoute(), context);
  }
}
