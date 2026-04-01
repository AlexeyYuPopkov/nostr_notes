import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nostr_notes/app/router/app_route/app_route.dart';
import 'package:nostr_notes/app/router/app_route/route_handler.dart';
import 'package:nostr_notes/app/router/app_router_path.dart';
import 'package:nostr_notes/app/router/screens_assembly/screens_assembly.dart';
import 'package:nostr_notes/auth/presentation/model/path_params.dart';

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
            child: RouteHandlerWidget(
              child: _screensAssembly.createEditNoteMarkdownScreen(params),
              onRoute: (route, context) {
                if (route is NotePreviewRoute) {
                  final router = GoRouter.of(context);

                  final path = router.state.matchedLocation
                      .split('/')
                      .popUntil(AppRouterPath.noteDetails)
                      .join();

                  return router.pushReplacement(
                    '/$path/${AppRouterPath.notePreview}',
                    extra: route.toExtra(),
                  );
                }
              },
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          );
        },
      ),
    ];
  }

  FutureOr<dynamic> possibleHandler(AppRoute route, BuildContext context) {
    final router = GoRouter.of(context);

    if (route is NotePreviewRoute) {
      return router.push(
        '${AppRouterPath.home}/${AppRouterPath.notePreview}',
        extra: route.toExtra(),
      );
    }

    return const UnhandledRouteResult();
  }
}

extension on List<String> {
  List<String> popUntil(String value, {bool inclusive = true}) {
    while (isNotEmpty && last != value) {
      removeLast();
    }

    if (inclusive && isNotEmpty && last == value) {
      removeLast();
    }

    return this;
  }
}

final class NoteDetailsRoute implements AppRoute {
  final String noteId;

  const NoteDetailsRoute({required this.noteId});

  Map<String, dynamic> toExtra() {
    return PathParams(id: noteId).toJson();
  }
}

final class NotePreviewRoute implements AppRoute {
  final String noteId;

  const NotePreviewRoute({required this.noteId});

  Map<String, dynamic> toExtra() {
    return PathParams(id: noteId).toJson();
  }
}

final class NewNoteRoute implements AppRoute {
  const NewNoteRoute();
}
