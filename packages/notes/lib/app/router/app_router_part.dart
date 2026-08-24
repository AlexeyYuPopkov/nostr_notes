part of 'app_router.dart';

final class HomeScreenCoordinatorImpl
    with NewLoginItemRoute, NewNoteRoute
    implements HomeScreenCoordinator {
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
    const path = '${AppRouterPath.home}/${AppRouterPath.noteDetails}';
    GoRouter.of(
      context,
    ).openInPane(path, extra: PathParams(id: noteId).toJson());
  }

  @override
  void onNewNoteRoute(BuildContext context) => newNote(context);

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
  void onAddLoginItemRoute(BuildContext context) => newLoginItem(context);

  @override
  void onLoginItemDetails(
    BuildContext context, {
    required LoginItem item,
    required bool readonly,
  }) {
    const path = '${AppRouterPath.home}${AppRouterPath.loginItemForm}';
    GoRouter.of(context).openInPane(
      path,
      extra: LoginItemDetailsParams(id: item.dTag, readonly: readonly).toJson(),
    );
  }
}

final class LoginItemFormScreenCoordinatorImpl
    with NewLoginItemRoute
    implements LoginItemFormScreenCoordinator {
  const LoginItemFormScreenCoordinatorImpl();

  @override
  void onCreateLoginItemRoute(BuildContext context) => newLoginItem(context);

  @override
  FutureOr<dynamic> onRawEventRoute(
    BuildContext context, {
    required String eventId,
  }) {
    final router = GoRouter.of(context);
    const path =
        '${AppRouterPath.home}${AppRouterPath.loginItemForm}/${AppRouterPath.rawEventDetails}';

    return router.push(
      path,
      extra: PathParamsEventId(eventId: eventId).toJson(),
    );
  }
}

final class HomeScreenEmptyStatePlaceholderCoordinatorImpl
    with NewLoginItemRoute, NewNoteRoute
    implements HomeScreenEmptyStatePlaceholderCoordinator {
  const HomeScreenEmptyStatePlaceholderCoordinatorImpl();
  @override
  void onCreateNoteRoute(BuildContext context) => newNote(context);

  @override
  void onCreateLoginItemRoute(BuildContext context) => newLoginItem(context);
}
