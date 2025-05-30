import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nostr_notes/auth/home_screen.dart';
import 'package:nostr_notes/unauth/presentation/onboarding/onboarding_screen.dart';

final class AppRouter {
  AppRouter();

  late final _router = GoRouter(
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
