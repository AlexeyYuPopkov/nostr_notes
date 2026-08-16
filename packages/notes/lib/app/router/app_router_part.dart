part of 'app_router.dart';

final class HomeScreenCoordinatorImpl implements HomeScreenCoordinator {
  final GlobalKey<ScaffoldState> _homeScaffoldKey;
  final GlobalKey<LeftDrawerState> _leftDrawerKey;

  const HomeScreenCoordinatorImpl({
    required GlobalKey<ScaffoldState> homeScaffoldKey,
    required GlobalKey<LeftDrawerState> leftDrawerKey,
  }) : _homeScaffoldKey = homeScaffoldKey,
       _leftDrawerKey = leftDrawerKey;

  @override
  FutureOr<dynamic> onNotePreviewRoute(
    BuildContext context, {
    required String noteId,
  }) {
    final router = GoRouter.of(context);

    return router.push(
      '${AppRouterPath.home}/${AppRouterPath.notePreview}',
      extra: PathParams(id: noteId).toJson(),
    );
  }

  @override
  void onNewNoteRoute(BuildContext context) {
    final router = GoRouter.of(context);
    const path = '${AppRouterPath.home}/${AppRouterPath.noteDetails}';
    return router.go(path);
  }

  @override
  void onEndDrawer() => _homeScaffoldKey.currentState?.openEndDrawer();

  @override
  void onAccountSwitcher() => _leftDrawerKey.currentState?.open();

  @override
  void onAddAccountRoute(BuildContext context) {
    GoRouter.of(context).push(
      AppRouterPath.onboarding,
      extra: const OnboardingScreenParams(addAccount: true).toJson(),
    );
  }

  @override
  void onAddLoginItemRoute(BuildContext context) {
    GoRouter.of(context).push(
      AppRouterPath.loginItemForm,
      extra: LoginItemDetailsParams(id: '', readonly: false).toJson(),
    );
  }

  @override
  void onLoginItemDetails(
    BuildContext context, {
    required LoginItem item,
    required bool readonly,
  }) {
    GoRouter.of(context).push(
      AppRouterPath.loginItemForm,
      extra: LoginItemDetailsParams(id: item.dTag, readonly: readonly).toJson(),
    );
  }
}

final class LoginItemFormScreenCoordinatorImpl
    implements LoginItemFormScreenCoordinator {
  const LoginItemFormScreenCoordinatorImpl();

  @override
  FutureOr<dynamic> onRawEventRoute(
    BuildContext context, {
    required String eventId,
  }) {
    final router = GoRouter.of(context);

    return router.push(
      '${AppRouterPath.loginItemForm}/${AppRouterPath.rawEventDetails}',
      extra: PathParamsEventId(eventId: eventId).toJson(),
    );
  }
}
