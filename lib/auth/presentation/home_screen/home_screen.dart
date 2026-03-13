import 'package:custom_adaptive_scaffold/custom_adaptive_scaffold.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:nostr_notes/app/icons/app_icons.dart';
import 'package:nostr_notes/app/l10n/localization.dart';
import 'package:nostr_notes/app/router/app_route/route_handler.dart';
import 'package:nostr_notes/app/router/app_router_path.dart';
import 'package:nostr_notes/app/router/drawer_router.dart' show DrawerRouter;
import 'package:nostr_notes/app/router/note_router.dart';
import 'package:nostr_notes/app/router/screens_assembly/screens_assembly.dart';
import 'package:nostr_notes/app/sizes.dart';
import 'package:nostr_notes/auth/presentation/home_screen/fab.dart';

import '../notes_list/notes_list.dart';

final class _LayoutConfig {
  /// [desktopScreenWidth = 600]
  static const desktopScreenWidth = 600.0;

  /// Body ratio range for resizable split view
  static const minBodyRatio = 0.25;
  static const maxBodyRatio = 0.5;
  static const defaultBodyRatio = 0.35;

  /// [drawerRatio = 0.7]
  static const drawerRatio = 0.7;

  /// [internalAnimations = false]
  static const internalAnimations = true;
}

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
  double _bodyRatio = _LayoutConfig.defaultBodyRatio;

  void _onResizeDividerDrag(double delta, double screenWidth) {
    final newRatio = (_bodyRatio + delta / screenWidth).clamp(
      _LayoutConfig.minBodyRatio,
      _LayoutConfig.maxBodyRatio,
    );
    if (newRatio != _bodyRatio) {
      setState(() => _bodyRatio = newRatio);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= _LayoutConfig.desktopScreenWidth;
    final drawerWidth = screenWidth * _LayoutConfig.drawerRatio;

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
    SlotLayoutConfig bodyConfig() => SlotLayout.from(
      key: const Key('Body Desktop'),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.only(left: Sizes.indent),
          child: Row(
            children: [
              Expanded(
                child: _NoteList(selectedNoteDTag: widget.selectedNoteDTag),
              ),
              _ResizeDivider(
                onDrag: (delta) => _onResizeDividerDrag(delta, screenWidth),
              ),
            ],
          ),
        );
      },
    );

    SlotLayoutConfig secondaryConfig() => SlotLayout.from(
      key: const Key('SecondaryBody Desktop'),
      builder: (_) =>
          Scaffold(body: widget.child, floatingActionButton: const Fab()),
    );

    SlotLayoutConfig smallConfig() => SlotLayout.from(
      key: const Key('Body Small'),
      builder: (_) => _MobileLayout(
        hasNote: widget.hasNote,
        selectedNoteDTag: widget.selectedNoteDTag,
        child: widget.child,
      ),
    );

    return AdaptiveLayout(
      bodyRatio: _bodyRatio,
      bodyOrientation: Axis.horizontal,
      internalAnimations: _LayoutConfig.internalAnimations,
      body: SlotLayout(
        config: {
          Breakpoints.small: smallConfig(),
          Breakpoints.medium: bodyConfig(),
          Breakpoints.mediumLarge: bodyConfig(),
          Breakpoints.large: bodyConfig(),
          Breakpoints.extraLarge: bodyConfig(),
        },
      ),
      secondaryBody: SlotLayout(
        config: {
          Breakpoints.medium: secondaryConfig(),
          Breakpoints.mediumLarge: secondaryConfig(),
          Breakpoints.large: secondaryConfig(),
          Breakpoints.extraLarge: secondaryConfig(),
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

final class _ResizeDivider extends StatelessWidget {
  final ValueChanged<double> onDrag;

  const _ResizeDivider({required this.onDrag});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.outlineVariant;
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: (details) => onDrag(details.delta.dx),
        child: SizedBox(
          width: Sizes.indent2x,
          child: Center(
            child: VerticalDivider(width: 1, thickness: 1, color: color),
          ),
        ),
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

final class NewNotePromptPlaceholder extends StatelessWidget {
  static const double iconRatio = 0.3;
  static const double opacity = 0.4;
  const NewNotePromptPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth * iconRatio;
        return Opacity(
          opacity: opacity,
          child: Padding(
            padding: const EdgeInsets.all(Sizes.indent4x),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: Sizes.indent2x,
                children: [
                  Image.asset(AppIcons.splash, width: size, height: size),
                  Text(
                    context.l10n.homeScreenEmptyStatePlaceholder,
                    style: theme.textTheme.displayMedium,
                  ),
                ],
              ),
            ),
          ),
        );
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
          // Positioned(
          //   right: Sizes.indentVariant2x,
          //   bottom: Sizes.indentVariant2x,
          //   child: Icon(
          //     Icons.add,
          //     size: 26.0,
          //     color: theme.colorScheme.primary,
          //   ),
          // ),
        ],
      ),
    );
  }

  void _onNewNote(BuildContext context) {
    RouteHandler.of(context)?.onRoute(const NewNoteRoute(), context);
  }
}
