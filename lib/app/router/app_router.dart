import 'dart:async';

import 'package:di_storage/di_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nostr_notes/app/di/app_di.dart';
import 'package:nostr_notes/app/router/app_router_path.dart';
import 'package:nostr_notes/auth/presentation/home_screen/home_screen.dart';
import 'package:nostr_notes/auth/presentation/model/path_params.dart';
import 'package:nostr_notes/auth/presentation/note/note_screen.dart';
import 'package:nostr_notes/common/domain/usecase/auth_usecase.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';
import 'package:nostr_notes/unauth/presentation/onboarding/onboarding_screen.dart';

final class AppRouter {
  late final SessionUsecase session = DiStorage.shared.resolve();
  late final authUsecase = DiStorage.shared.resolve<AuthUsecase>();
  late final StreamSubscription sessionSubscription;

  AppRouter() {
    authUsecase.restore().then(
          (_) => _createSessionSubscription(),
        );
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
      GoRoute(
        name: AppRouterName.home,
        path: AppRouterPath.home,
        builder: (BuildContext context, GoRouterState state) {
          return const HomeScreen();
        },
        routes: [
          GoRoute(
            name: AppRouterName.note,
            path: AppRouterName.note,
            builder: (BuildContext context, GoRouterState state) {
              final params = PathParams.fromJson(state.uri.queryParameters);
              return NoteScreen(pathParams: params);
            },
          ),
        ],
      ),
    ],
  );

  GoRouter get router => _router;
}
