import 'package:auto_route/auto_route.dart';
import 'package:chat/router/app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: OnboardingRoute.page, initial: true),
  ];
}

// @AutoRoute()
// class OnboardingScreenRoute extends AutoRoute {
//   const OnboardingScreenRoute();
// }
