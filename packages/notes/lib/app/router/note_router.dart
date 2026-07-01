import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nostr_notes/app/router/app_router_path.dart';
import 'package:nostr_notes/app/router/screens_assembly/screens_assembly.dart';
import 'package:nostr_notes/auth/presentation/edit_note_markdown_screen/edit_note_markdown_screen.dart';
import 'package:nostr_notes/auth/presentation/model/path_params.dart';
import 'package:nostr_notes/auth/presentation/note_preview_screen/note_preview_screen.dart';

part 'note_router_part.dart';

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
            child: _screensAssembly.createNotePreview(
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
}
