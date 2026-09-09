part of 'note_router.dart';

final class NotePreviewScreenCoordinatorImpl
    with NewNoteRoute
    implements NotePreviewScreenCoordinator {
  const NotePreviewScreenCoordinatorImpl();

  @override
  void onCreateNoteRoute(BuildContext context) => newNote(context);

  @override
  FutureOr<dynamic> onRawEventRoute(
    BuildContext context, {
    required String eventId,
  }) {
    final router = GoRouter.of(context);
    const path = '${AppRouterPath.home}/${AppRouterPath.rawEventDetails}';

    return router.push(
      path,
      extra: PathParamsEventId(eventId: eventId).toJson(),
    );
  }
}
