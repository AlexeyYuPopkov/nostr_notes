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
import 'package:nostr_notes/auth/domain/model/login_item.dart';
import 'package:nostr_notes/auth/presentation/home_screen/home_screen.dart';
import 'package:nostr_notes/auth/presentation/home_screen/left_drawer.dart';
import 'package:nostr_notes/auth/presentation/login_item_form/login_item_form_screen.dart';
import 'package:nostr_notes/auth/presentation/model/path_params.dart';
import 'package:nostr_notes/auth/presentation/settings/settings/settings_screen_routes.dart';
import 'package:nostr_notes/auth/presentation/widgets/new_note_prompt_placeholder.dart';
import 'package:nostr_notes/common/domain/usecase/auth_usecase.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';
import 'package:nostr_notes/unauth/presentation/onboarding/onboarding_screen.dart';
import 'package:nostr_notes/unauth/presentation/onboarding/params/onboarding_screen_params.dart';
import 'package:rxdart/transformers.dart';

import '../../auth/presentation/login_item_form/bloc/login_item_details_params.dart';

part 'app_router_part.dart';

final class AppRouter {
  late final SessionUsecase session = DiStorage.shared.resolve();
  late final authUsecase = DiStorage.shared.resolve<AuthUsecase>();
  late final StreamSubscription sessionSubscription;
  final ScreensAssembly _screensAssembly;
  late final noteRouter = NoteRouter(screensAssembly: _screensAssembly);
  final _navigatorKey = GlobalKey<NavigatorState>();

  AppRouter({ScreensAssembly screensAssembly = const AppScreensAssembly()})
    : _screensAssembly = screensAssembly {
    authUsecase.restore().then((_) => _createSessionSubscription());
  }

  void _createSessionSubscription() {
    sessionSubscription = session.sessionStream
        .distinct(
          (a, b) => a.isUnlocked == b.isUnlocked && a.pubkey == b.pubkey,
        )
        .doOnData((session) {
          if (session.isAuth && session.isUnlocked) {
            Di.instance.bindAuthModules();
          }
        })
        .listen((session) async {
          if (!session.isAuth || !session.isUnlocked) {
            _dismissOverlays();
          }
          _router.refresh();
        });
  }

  void _dismissOverlays() {
    final navigatorState = _navigatorKey.currentState;
    if (navigatorState != null) {
      ScaffoldMessenger.maybeOf(navigatorState.context)?.clearSnackBars();
      navigatorState.popUntil((route) => route is! PopupRoute);
    }
  }

  final _homeScaffoldKey = GlobalKey<ScaffoldState>(
    debugLabel: 'GlobalKey.home_scaffold',
  );

  final _leftDrawerKey = GlobalKey<LeftDrawerState>(
    debugLabel: 'GlobalKey.left_drawer',
  );

  late final _router = GoRouter(
    navigatorKey: _navigatorKey,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      if (state.matchedLocation.contains(AppRouterPath.contacts) ||
          state.matchedLocation.contains(AppRouterPath.privacyPolicy) ||
          state.matchedLocation.contains(AppRouterPath.apkDistribution)) {
        return null;
      }

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
          final extra = state.extra;
          final OnboardingScreenParams params = extra is Map<String, dynamic>
              ? OnboardingScreenParams.fromJson(extra)
              : const OnboardingScreenParams(addAccount: false);

          return RouteHandlerWidget(
            child: OnboardingScreen(params: params),
            onRoute: (route, context) {
              if (route is ApkDistributionRoute) {
                return GoRouter.of(
                  context,
                ).pushNamed(AppRouterName.apkDistribution, extra: true);
              }

              return RouteHandler.of(context)?.onRoute(route, context);
            },
          );
        },
        routes: [
          GoRoute(
            path: AppRouterPath.contacts,
            builder: (BuildContext context, GoRouterState state) {
              return _screensAssembly.createContactsScreen(
                showAppBar: state.extra != null,
              );
            },
          ),
          GoRoute(
            path: AppRouterPath.privacyPolicy,
            builder: (BuildContext context, GoRouterState state) {
              return _screensAssembly.createPrivacyPolicyScreen(
                showAppBar: state.extra != null,
              );
            },
          ),
          GoRoute(
            name: AppRouterName.apkDistribution,
            path: AppRouterPath.apkDistribution,
            builder: (BuildContext context, GoRouterState state) {
              return _screensAssembly.createApkDistributionScreen(
                showAppBar: state.extra != null,
              );
            },
          ),
        ],
      ),

      ShellRoute(
        builder: (context, state, child) {
          final extra = state.extra;
          final selectedNoteDTag = extra is Map<String, dynamic>
              ? PathParams.fromJson(extra).id
              : null;
          final hasNote =
              state.fullPath?.contains(AppRouterPath.noteDetails) == true ||
              state.fullPath?.contains(AppRouterPath.editNote) == true;

          return Scaffold(
            body: HomeScreen(
              scaffoldKey: _homeScaffoldKey,
              leftDrawerKey: _leftDrawerKey,
              screensAssembly: _screensAssembly,
              coordinator: HomeScreenCoordinatorImpl(
                homeScaffoldKey: _homeScaffoldKey,
                leftDrawerKey: _leftDrawerKey,
              ),
              hasNote: hasNote,
              selectedNoteDTag: selectedNoteDTag,
              child: child,
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
            routes: [
              ...noteRouter.getRoutes(),
              GoRoute(
                path: AppRouterPath.loginItemForm,
                builder: (BuildContext context, GoRouterState state) {
                  final extra = state.extra;
                  final params = LoginItemDetailsParams.fromJson(
                    extra as Map<String, dynamic>,
                  );
                  return _screensAssembly.createLoginItemFormScreen(
                    params: params,
                    coordinator: const LoginItemFormScreenCoordinatorImpl(),
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
            ],
          ),
        ],
      ),
    ],
  );

  GoRouter get router => _router;
}
