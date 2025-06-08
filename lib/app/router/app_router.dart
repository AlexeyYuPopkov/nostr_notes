import 'dart:async';

import 'package:di_storage/di_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nostr_notes/auth/home_screen.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';
import 'package:nostr_notes/unauth/presentation/onboarding/onboarding_screen.dart';

final class AppRouter {
  late final SessionUsecase session = DiStorage.shared.resolve();
  late final StreamSubscription sessionSubscription;

  AppRouter() {
    _createSessionSubscription();
  }

  void _createSessionSubscription() {
    sessionSubscription = session.sessionStream
        .distinct((a, b) => a.isUnlocked == b.isUnlocked)
        .listen((session) => _router.refresh());
  }

  late final _router = GoRouter(
    redirect: (context, state) {
      final session = this.session.currentSession;

      if (session.isAuth && session.isUnlocked) {
        return '/home';
      } else {
        return '/';
      }
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return const OnboardingScreen();
        },
      ),
      GoRoute(
        path: '/home',
        builder: (BuildContext context, GoRouterState state) {
          return const HomeScreen();
        },
      ),
    ],
  );

  GoRouter get router => _router;
}
