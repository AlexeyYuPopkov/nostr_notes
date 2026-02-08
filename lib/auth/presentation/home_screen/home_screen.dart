import 'package:custom_adaptive_scaffold/custom_adaptive_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nostr_notes/app/router/app_route/route_handler.dart';
import 'package:nostr_notes/app/router/app_router_path.dart';
import 'package:nostr_notes/app/router/drawer_router.dart' show DrawerRouter;
import 'package:nostr_notes/app/router/note_router.dart';
import 'package:nostr_notes/app/router/screens_assembly/screens_assembly.dart';
import 'package:nostr_notes/app/sizes.dart';

import '../notes_list/notes_list.dart';

final class _LayoutConfig {
  static const desktopScreenWidth = 600.0;
  static const bodyRatio = 0.3;
  static const internalAnimations = false;
}

final class HomeScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final ScreensAssembly screensAssembly;
  final Widget child;
  final bool hasNote;

  const HomeScreen({
    super.key,
    required this.scaffoldKey,
    required this.screensAssembly,
    required this.child,
    required this.hasNote,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= _LayoutConfig.desktopScreenWidth;
    final sideWidth = screenWidth * _LayoutConfig.bodyRatio;

    return Scaffold(
      key: scaffoldKey,
      floatingActionButton: Builder(
        builder: (context) {
          return FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () => _onNewNote(context),
          );
        },
      ),
      endDrawer: SizedBox(
        width: isDesktop ? sideWidth : double.infinity,
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
    final bodyConfig = SlotLayout.from(
      key: const Key('Body Desktop'),
      builder: (_) => Row(
        children: [
          const Expanded(child: _NoteList()),
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: Theme.of(context).dividerColor,
          ),
        ],
      ),
    );
    final secondaryConfig = SlotLayout.from(
      key: const Key('SecondaryBody Desktop'),
      builder: (_) => child,
    );

    return AdaptiveLayout(
      bodyRatio: _LayoutConfig.bodyRatio,
      bodyOrientation: Axis.horizontal,
      internalAnimations: _LayoutConfig.internalAnimations,
      body: SlotLayout(
        config: {
          Breakpoints.small: SlotLayout.from(
            key: const Key('Body Small'),
            builder: (_) => _MobileLayout(hasNote: hasNote, child: child),
          ),
          Breakpoints.medium: bodyConfig,
          Breakpoints.mediumLarge: bodyConfig,
          Breakpoints.large: bodyConfig,
          Breakpoints.extraLarge: bodyConfig,
        },
      ),
      secondaryBody: SlotLayout(
        config: {
          Breakpoints.medium: secondaryConfig,
          Breakpoints.mediumLarge: secondaryConfig,
          Breakpoints.large: secondaryConfig,
          Breakpoints.extraLarge: secondaryConfig,
        },
      ),
    );
  }

  void _onNewNote(BuildContext context) {
    RouteHandler.of(context)?.onRoute(const NewNoteRoute(), context);
  }
}

final class _MobileLayout extends StatelessWidget {
  final Widget child;
  final bool hasNote;
  const _MobileLayout({required this.child, required this.hasNote});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const _NoteList(),
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
  const _NoteList();

  @override
  Widget build(BuildContext context) {
    return NotesList(
      selectedNoteDTag: null,
      onTap: (note) {
        RouteHandler.of(
          context,
        )?.onRoute(NotePreviewRoute(noteId: note.dTag), context);
      },
    );
  }
}

final class NewNotePromptPlaceholder extends StatelessWidget {
  const NewNotePromptPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Sizes.indent2x),
      child: Center(
        child: Text(
          'Выберите заметку или создайте новую',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}
