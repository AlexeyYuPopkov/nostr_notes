part of 'app_router.dart';

final class HomeScreenCoordinatorImpl
    with _NewLoginItem, _NewNote
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
    final router = GoRouter.of(context);
    const path = '${AppRouterPath.home}/${AppRouterPath.noteDetails}';
    return router.push(path, extra: PathParams(id: noteId).toJson());
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
  void onAddLoginItemRoute(BuildContext context) => loginItem(context);

  @override
  void onLoginItemDetails(
    BuildContext context, {
    required LoginItem item,
    required bool readonly,
  }) {
    final router = GoRouter.of(context);
    const path = '${AppRouterPath.home}${AppRouterPath.loginItemForm}';
    final extra = LoginItemDetailsParams(
      id: item.dTag,
      readonly: readonly,
    ).toJson();
    if (router.state.fullPath == AppRouterPath.home) {
      router.push(path, extra: extra);
    } else {
      router.pushReplacement(path, extra: extra);
    }
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
    const path =
        '${AppRouterPath.home}${AppRouterPath.loginItemForm}/${AppRouterPath.rawEventDetails}';

    return router.push(
      path,
      extra: PathParamsEventId(eventId: eventId).toJson(),
    );
  }
}

final class HomeScreenEmptyStatePlaceholderCoordinatorImpl
    with _NewLoginItem, _NewNote
    implements HomeScreenEmptyStatePlaceholderCoordinator {
  const HomeScreenEmptyStatePlaceholderCoordinatorImpl();
  @override
  void onCreateNoteRoute(BuildContext context) => newNote(context);

  @override
  void onCreateLoginItemRoute(BuildContext context) => loginItem(context);
}

mixin _NewLoginItem {
  void loginItem(BuildContext context) {
    final router = GoRouter.of(context);
    final extra = LoginItemDetailsParams(id: '', readonly: false).toJson();
    const path = '${AppRouterPath.home}${AppRouterPath.loginItemForm}';

    if (router.state.fullPath == AppRouterPath.home) {
      router.push(path, extra: extra);
    } else {
      router.pushReplacement(path, extra: extra);
    }
  }
}

mixin _NewNote {
  void newNote(BuildContext context) {
    final router = GoRouter.of(context);
    const path = '${AppRouterPath.home}/${AppRouterPath.editNote}';

    if (router.state.fullPath == AppRouterPath.home) {
      router.push(path);
    } else {
      router.pushReplacement(path);
    }
  }
}
