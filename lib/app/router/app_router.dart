import 'dart:async';

import 'package:di_storage/di_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nostr_notes/app/di/app_di.dart';
import 'package:nostr_notes/app/router/app_route/route_handler.dart';
import 'package:nostr_notes/app/router/app_router_path.dart';
import 'package:nostr_notes/app/router/note_router.dart';
import 'package:nostr_notes/app/router/screens_assembly/app_screens_assembly.dart';
import 'package:nostr_notes/app/router/screens_assembly/screens_assembly.dart';
import 'package:nostr_notes/auth/presentation/home_screen/home_screen.dart';
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
        .listen((session) {
          if (session.isAuth && session.isUnlocked) {
            AppDi.bindAuthModules();
          }
          _router.refresh();
        });
  }

  // final GlobalKey<NavigatorState> drawerNavigatorKey =
  //     GlobalKey<NavigatorState>();

  late final _router = GoRouter(
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
          return RouteHandlerWidget(
            child: HomeScreen(
              screensAssembly: _screensAssembly,
              hasNote: state.fullPath?.contains('note') == true,
              // drawerNavigatorKey: drawerNavigatorKey,
              child: child,
            ),
            onRoute: (route, context) {
              if (route is NotePreviewRoute) {
                return noteRouter.possibleHandler(route, context);
              } else if (route is NewNoteRoute) {
                final router = GoRouter.of(context);
                final path = [
                  router.state.matchedLocation,
                  AppRouterPath.noteDetails,
                ].join('/');

                return router.push(path);
              }
              // else if (route is PreferencesRoute) {
              //   final router = GoRouter.of(context);

              //   final path = StringBuffer(router.state.matchedLocation);
              //   path.write('/app_settings');

              //   return Navigator.of(
              //     drawerNavigatorKey.currentContext!,
              //   ).pushNamed('/app_settings');
              // }
            },
          );
        },
        routes: [
          // ShellRoute(
          //   navigatorKey: drawerNavigatorKey,
          //   builder: (context, state, child) {
          //     return RouteHandlerWidget(
          //       child: Scaffold(body: child),
          //       onRoute: (route, context) {
          //         print('Drawer route: $route');
          //       },
          //     );
          //   },
          //   routes: [
          //     GoRoute(
          //       name: AppRouterName.home,
          //       path: AppRouterPath.home,
          //       builder: (BuildContext context, GoRouterState state) {
          //         return const NewNotePromptPlaceholder();
          //       },
          //       routes: [...noteRouter.getRoutes()],
          //     ),
          //     GoRoute(
          //       path: 'app_settings',
          //       builder: (BuildContext context, GoRouterState state) {
          //         return _screensAssembly.createAppSettingsScreen();
          //       },
          //       // routes: [...noteRouter.getRoutes()],
          //     ),
          //     // ...noteRouter.getRoutes(),
          //   ],
          // ),
          GoRoute(
            name: AppRouterName.home,
            path: AppRouterPath.home,
            builder: (BuildContext context, GoRouterState state) {
              return const NewNotePromptPlaceholder();
            },
            routes: [...noteRouter.getRoutes()],
          ),
          // // ...noteRouter.getRoutes(),
        ],
      ),
    ],
  );

  GoRouter get router => _router;
}
