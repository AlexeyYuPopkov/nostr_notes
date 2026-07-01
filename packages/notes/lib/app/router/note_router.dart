import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nostr_notes/app/router/app_route/app_route.dart';
import 'package:nostr_notes/app/router/app_route/route_handler.dart';
import 'package:nostr_notes/app/router/app_router_path.dart';
import 'package:nostr_notes/app/router/screens_assembly/screens_assembly.dart';
import 'package:nostr_notes/auth/presentation/edit_note_markdown_screen/edit_note_markdown_screen.dart';
import 'package:nostr_notes/auth/presentation/home_screen/home_screen.dart';
import 'package:nostr_notes/auth/presentation/model/path_params.dart';

final class HomeScreenCoordinatorImpl implements HomeScreenCoordinator {
  final GlobalKey<ScaffoldState> _homeScaffoldKey;

  const HomeScreenCoordinatorImpl({
    required GlobalKey<ScaffoldState> homeScaffoldKey,
  }) : _homeScaffoldKey = homeScaffoldKey;

  @override
  FutureOr<dynamic> onNotePreviewRoute(
    BuildContext context, {
    required String noteId,
  }) {
    final router = GoRouter.of(context);

    return router.push(
      '${AppRouterPath.home}/${AppRouterPath.notePreview}',
      extra: PathParams(id: noteId).toJson(),
    );
  }

  @override
  void onNewNoteRoute(BuildContext context) {
    final router = GoRouter.of(context);
    const path = '${AppRouterPath.home}/${AppRouterPath.noteDetails}';
    return router.go(path);
  }

  @override
  void onEndDrawer() => _homeScaffoldKey.currentState?.openEndDrawer();
}

final class EditMarkdownNoteScreenCoordinatorImpl
    implements EditMarkdownNoteScreenCoordinator {
  const EditMarkdownNoteScreenCoordinatorImpl();

  @override
  FutureOr<dynamic> onNotePreviewRoute(
    BuildContext context, {
    required String noteId,
  }) {
    final router = GoRouter.of(context);

    // The new-note editor lives at `/home/note_details`; replace it with the
    // preview (`/home/note_preview`, a sibling under `home`) so "back" from the
    // preview returns home instead of the just-created empty editor.
    return router.pushReplacement(
      '${AppRouterPath.home}/${AppRouterPath.notePreview}',
      extra: PathParams(id: noteId).toJson(),
    );
  }
}

final class NoteRouter {
  final ScreensAssembly _screensAssembly;

  const NoteRouter({required ScreensAssembly screensAssembly})
    : _screensAssembly = screensAssembly;

  List<GoRoute> getRoutes() {
    return [
      GoRoute(
        path: AppRouterPath.notePreview,
        pageBuilder: (BuildContext context, GoRouterState state) {
          final extra = state.extra as Map<String, dynamic>;
          final params = PathParams.fromJson(extra);
          return CustomTransitionPage(
            key: state.pageKey,
            child: RouteHandlerWidget(
              child: _screensAssembly.createNotePreview(params),
              onRoute: (route, context) {
                if (route is NoteDetailsRoute) {
                  final router = GoRouter.of(context);

                  final uri = Uri(
                    pathSegments: [
                      AppRouterName.home,
                      AppRouterPath.noteDetails,
                    ],
                  );

                  return router.push('/${uri.path}', extra: route.toExtra());
                } else if (route is RawEventRoute) {
                  final router = GoRouter.of(context);

                  final uri = Uri(
                    pathSegments: [
                      AppRouterName.home,
                      AppRouterPath.noteDetails,
                      AppRouterPath.rawEventDetails,
                    ],
                  );

                  return router.push('/${uri.path}', extra: route.toExtra());
                }

                return RouteHandler.of(context)?.onRoute(route, context);
              },
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          );
        },
      ),
      GoRoute(
        path: AppRouterPath.noteDetails,
        pageBuilder: (BuildContext context, GoRouterState state) {
          final extra = state.extra as Map<String, dynamic>?;
          final params = extra == null ? null : PathParams.fromJson(extra);

          return CustomTransitionPage(
            key: state.pageKey,
            child: _screensAssembly.createEditNoteMarkdownScreen(
              params,
              coordinator: const EditMarkdownNoteScreenCoordinatorImpl(),
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          );
        },
        routes: [
          GoRoute(
            path: AppRouterPath.rawEventDetails,
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>;
              final params = PathParamsEventId.fromJson(extra);
              return _screensAssembly.createRawEventScreen(params);
            },
          ),
        ],
      ),
    ];
  }

  FutureOr<dynamic> possibleHandler(AppRoute route, BuildContext context) {
    return const UnhandledRouteResult();
  }
}

final class NoteDetailsRoute implements AppRoute {
  final String noteId;

  const NoteDetailsRoute({required this.noteId});

  Map<String, dynamic> toExtra() {
    return PathParams(id: noteId).toJson();
  }
}

final class RawEventRoute implements AppRoute {
  final String eventId;

  const RawEventRoute({required this.eventId});

  Map<String, dynamic> toExtra() {
    return PathParamsEventId(eventId: eventId).toJson();
  }
}

// final class NotePreviewRoute implements AppRoute {
//   final String noteId;

//   const NotePreviewRoute({required this.noteId});

//   Map<String, dynamic> toExtra() {
//     return PathParams(id: noteId).toJson();
//   }
// }

// final class NewNoteRoute implements AppRoute {
//   const NewNoteRoute();
// }
