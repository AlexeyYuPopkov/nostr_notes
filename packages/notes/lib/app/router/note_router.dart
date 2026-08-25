import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nostr_notes/app/router/app_router_path.dart';
import 'package:nostr_notes/app/router/create_routes.dart';
import 'package:nostr_notes/app/router/screens_assembly/screens_assembly.dart';
import 'package:nostr_notes/auth/presentation/model/path_params.dart';
import 'package:nostr_notes/auth/presentation/note_screen/note_preview_screen/note_preview_screen.dart';

part 'note_router_part.dart';

final class NoteRouter {
  final ScreensAssembly _screensAssembly;

  const NoteRouter({required ScreensAssembly screensAssembly})
    : _screensAssembly = screensAssembly;

  List<GoRoute> getRoutes() {
    return [
      GoRoute(
        path: AppRouterPath.noteDetails,
        pageBuilder: (BuildContext context, GoRouterState state) {
          final extra = state.extra as Map<String, dynamic>;
          final params = PathParams.fromJson(extra);
          return CustomTransitionPage(
            key: state.pageKey,
            child: _screensAssembly.createNoteScreen(
              params,
              coordinator: const NotePreviewScreenCoordinatorImpl(),
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          );
        },
      ),
      GoRoute(
        path: AppRouterPath.editNote,
        pageBuilder: (BuildContext context, GoRouterState state) {
          final extra = state.extra as Map<String, dynamic>?;
          final params = extra == null ? null : PathParams.fromJson(extra);

          return CustomTransitionPage(
            key: state.pageKey,
            child: _screensAssembly.createNoteScreen(
              params,
              coordinator: const NotePreviewScreenCoordinatorImpl(),
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
}
