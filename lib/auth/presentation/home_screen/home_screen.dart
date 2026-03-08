import 'package:custom_adaptive_scaffold/custom_adaptive_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nostr_notes/app/l10n/localization.dart';
import 'package:nostr_notes/app/router/app_route/route_handler.dart';
import 'package:nostr_notes/app/router/app_router_path.dart';
import 'package:nostr_notes/app/router/drawer_router.dart' show DrawerRouter;
import 'package:nostr_notes/app/router/note_router.dart';
import 'package:nostr_notes/app/router/screens_assembly/screens_assembly.dart';
import 'package:nostr_notes/app/sizes.dart';

import '../notes_list/notes_list.dart';

final class _LayoutConfig {
  /// [desktopScreenWidth = 600]
  static const desktopScreenWidth = 600.0;

  /// [bodyRatio = 0.3]
  static const bodyRatio = 0.35;

  /// [drawerRatio = 0.7]
  static const drawerRatio = 0.7;

  /// [internalAnimations = false]
  static const internalAnimations = true;
}

final class HomeScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= _LayoutConfig.desktopScreenWidth;
    // final sideWidth = screenWidth * _LayoutConfig.bodyRatio;
    final drawerWidth = screenWidth * _LayoutConfig.drawerRatio;

    return Scaffold(
      key: scaffoldKey,
      // floatingActionButton: Builder(
      //   builder: (context) {
      //     return FloatingActionButton(
      //       elevation: 2,
      //       shape: RoundedRectangleBorder(
      //         borderRadius: BorderRadius.circular(Sizes.radiusVariant),
      //       ),
      //       child: const Icon(Icons.add),
      //       onPressed: () => _onNewNote(context),
      //     );
      //   },
      // ),
      endDrawer: SizedBox(
        width: isDesktop ? drawerWidth : double.infinity,
        child: DrawerRouter(screensAssembly: screensAssembly),
      ),
      body: RouteHandlerWidget(
        onRoute: (route, ctx) {
          if (route is NotePreviewRoute) {
            final router = GoRouter.of(ctx);

            final currentUri = Uri.parse(router.state.matchedLocation);
            final uri = Uri(
              pathSegments: [AppRouterName.home, AppRouterPath.notePreview],
            );

            if (currentUri.pathSegments.contains(AppRouterPath.noteDetails)) {
              Navigator.of(ctx).maybePop();
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
          // else if (route is NoteDetailsRoute) {
          //   final router = GoRouter.of(ctx);
          //   final uri = Uri(
          //     pathSegments: [AppRouterName.home, AppRouterPath.noteDetails],
          //   );

          //   return router.push('/${uri.path}', extra: route.toExtra());
          // }
          return RouteHandler.of(context)?.onRoute(route, ctx);
        },
        child: _buildAdaptiveLayout(context),
      ),
    );
  }

  Widget _buildAdaptiveLayout(BuildContext context) {
    SlotLayoutConfig bodyConfig() => SlotLayout.from(
      key: const Key('Body Desktop'),
      builder: (_) => Row(
        children: [
          Expanded(child: _NoteList(selectedNoteDTag: selectedNoteDTag)),
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ],
      ),
    );

    SlotLayoutConfig secondaryConfig() => SlotLayout.from(
      key: const Key('SecondaryBody Desktop'),
      builder: (_) => Scaffold(
        body: child,
        floatingActionButton: _Fab(onPressed: () {}),
      ),
    );

    SlotLayoutConfig smallConfig() => SlotLayout.from(
      key: const Key('Body Small'),
      builder: (_) => _MobileLayout(
        hasNote: hasNote,
        selectedNoteDTag: selectedNoteDTag,
        child: child,
      ),
    );

    return AdaptiveLayout(
      bodyRatio: _LayoutConfig.bodyRatio,
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
    return Stack(
      children: [
        _NoteList(selectedNoteDTag: selectedNoteDTag),
        AnimatedSlide(
          offset: hasNote ? const Offset(0.0, 0.0) : const Offset(1.0, 0.0),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: hasNote
              ? child
              : Scaffold(
                  appBar: AppBar(leading: BackButton(onPressed: () {})),
                ),
        ),
      ],
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

final class _Fab extends StatelessWidget {
  final VoidCallback onPressed;
  const _Fab({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Sizes.radiusVariant),
      ),
      onPressed: () => _onNewNote(context),
      child: const Icon(Icons.add),
    );
  }

  void _onNewNote(BuildContext context) {
    // GoRouter.of(context).pop();
    RouteHandler.of(context)?.onRoute(const NewNoteRoute(), context);
  }
}

final class NewNotePromptPlaceholder extends StatelessWidget {
  const NewNotePromptPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(Sizes.indent4x),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: Sizes.indent2x,
          children: [
            Icon(
              Icons.note_alt_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            Text(
              context.l10n.homeScreenEmptyStatePlaceholder,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
