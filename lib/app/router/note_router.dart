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
        name: AppRouterName.note,
        path: AppRouterName.note,
        builder: (BuildContext context, GoRouterState state) {
          final params = PathParams.fromJson(state.uri.queryParameters);
          return _screensAssembly.createNoteScreen(params);
        },
      ),
      GoRoute(
        path: AppRouterPath.notePreview,
        builder: (BuildContext context, GoRouterState state) {
          final extra = state.extra as Map<String, dynamic>;
          final params = PathParams.fromJson(extra);
          return RouteHandlerWidget(
            child: _screensAssembly.createNotePreview(params),
            onRoute: (route, context) {
              if (route is NoteDetailsRoute) {
                final router = GoRouter.of(context);

                final path = router.state.matchedLocation
                    .split('/')
                    .popUntil(AppRouterPath.notePreview)
                    .join();
                return router.pushReplacement(
                  '/$path/${AppRouterPath.noteDetails}',
                  extra: PathParams(id: route.noteId).toJson(),
                );
              }

              return const UnhandledRouteResult();
            },
          );
        },
      ),
      GoRoute(
        path: AppRouterPath.noteDetails,
        builder: (BuildContext context, GoRouterState state) {
          final extra = state.extra as Map<String, dynamic>;
          final params = PathParams.fromJson(extra);
          return _screensAssembly.createNoteDetailsScreen(params);
        },
      ),
    ];
  }

  FutureOr<dynamic> possibleHandler(AppRoute route, BuildContext context) {
    final router = GoRouter.of(context);
    final path = router.state.matchedLocation;

    if (route is NotePreviewRoute) {
      return router.push(
        '$path/${AppRouterPath.notePreview}',
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
