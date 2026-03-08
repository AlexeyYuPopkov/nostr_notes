import 'dart:async';

import 'package:di_storage/di_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nostr_notes/app/di/app_di.dart';
import 'package:nostr_notes/app/router/app_route/route_handler.dart';
import 'package:nostr_notes/app/router/app_router_path.dart';
import 'package:nostr_notes/app/router/drawer_router.dart' show OnEndDrawer;
import 'package:nostr_notes/app/router/note_router.dart';
import 'package:nostr_notes/app/router/screens_assembly/app_screens_assembly.dart';
import 'package:nostr_notes/app/router/screens_assembly/screens_assembly.dart';
import 'package:nostr_notes/auth/presentation/home_screen/home_screen.dart';
import 'package:nostr_notes/auth/presentation/model/path_params.dart';
import 'package:nostr_notes/common/domain/usecase/auth_usecase.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';
import 'package:nostr_notes/unauth/presentation/onboarding/onboarding_screen.dart';

final class AppRouter {
  late final SessionUsecase session = DiStorage.shared.resolve();
  late final authUsecase = DiStorage.shared.resolve<AuthUsecase>();
  late final StreamSubscription sessionSubscription;
  final ScreensAssembly _screensAssembly;
  late final noteRouter = NoteRouter(screensAssembly: _screensAssembly);

  AppRouter({ScreensAssembly screensAssembly = const AppScreensAssembly()})
    : _screensAssembly = screensAssembly {
    authUsecase.restore().then((_) => _createSessionSubscription());
  }

  void _createSessionSubscription() {
    sessionSubscription = session.sessionStream
        .distinct((a, b) => a.isUnlocked == b.isUnlocked)
        .listen((session) async {
          if (session.isAuth && session.isUnlocked) {
            await Di.instance.bindAuthModules();
          }
          _router.refresh();
        });
  }

  final _homeScaffoldKey = GlobalKey<ScaffoldState>(
    debugLabel: 'GlobalKey.home_scaffold',
  );

  late final _router = GoRouter(
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final session = this.session.currentSession;

      if (session.isAuth && session.isUnlocked) {
        return null;
      } else {
        return AppRouterPath.onboarding;
      }
    },
    routes: [
      GoRoute(
        name: AppRouterName.onboarding,
        path: AppRouterPath.onboarding,
        builder: (BuildContext context, GoRouterState state) {
          return const OnboardingScreen();
        },
      ),
      ShellRoute(
        builder: (context, state, child) {
          final extra = state.extra;
          final selectedNoteDTag = extra is Map<String, dynamic>
              ? PathParams.fromJson(extra).id
              : null;
          return Scaffold(
            body: Builder(
              builder: (context) {
                return RouteHandlerWidget(
                  child: HomeScreen(
                    scaffoldKey: _homeScaffoldKey,
                    screensAssembly: _screensAssembly,
                    hasNote: state.fullPath?.contains('note') == true,
                    selectedNoteDTag: selectedNoteDTag,
                    child: child,
                  ),
                  onRoute: (route, ctx) async {
                    if (route is NotePreviewRoute) {
                      return noteRouter.possibleHandler(route, ctx);
                    } else if (route is NewNoteRoute) {
                      final router = GoRouter.of(ctx);
                      final path = [
                        router.state.matchedLocation,
                        AppRouterPath.noteDetails,
                      ].join('/');

                      return router.push(path);
                    } else if (route is OnEndDrawer) {
                      _homeScaffoldKey.currentState?.openEndDrawer();
                      return;
                    }

                    return RouteHandler.of(context)?.onRoute(route, ctx);
                  },
                );
              },
            ),
          );
        },
        routes: [
          GoRoute(
            name: AppRouterName.home,
            path: AppRouterPath.home,
            builder: (BuildContext context, GoRouterState state) {
              return const NewNotePromptPlaceholder();
            },
            routes: [...noteRouter.getRoutes()],
          ),
        ],
      ),
    ],
  );

  GoRouter get router => _router;
}
