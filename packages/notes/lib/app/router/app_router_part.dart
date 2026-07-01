part of 'app_router.dart';

final class HomeScreenCoordinatorImpl implements HomeScreenCoordinator {
  final GlobalKey<ScaffoldState> _homeScaffoldKey;

  const HomeScreenCoordinatorImpl({
    required GlobalKey<ScaffoldState> homeScaffoldKey,
  }) : _homeScaffoldKey = homeScaffoldKey;

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
}
