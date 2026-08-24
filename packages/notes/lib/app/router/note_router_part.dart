part of 'note_router.dart';

final class EditMarkdownNoteScreenCoordinatorImpl
    implements EditMarkdownNoteScreenCoordinator {
  const EditMarkdownNoteScreenCoordinatorImpl();

  @override
  FutureOr<dynamic> onNotePreviewRoute(
    BuildContext context, {
    required String noteId,
  }) {
    final router = GoRouter.of(context);

    // The new-note editor lives at `/home/note_details`; replace it with the
    // preview (`/home/note_preview`, a sibling under `home`) so "back" from the
    // preview returns home instead of the just-created empty editor.
    return router.pushReplacement(
      '${AppRouterPath.home}/${AppRouterPath.noteDetails}',
      extra: PathParams(id: noteId).toJson(),
    );
  }
}

final class NotePreviewScreenCoordinatorImpl
    with NewNoteRoute
    implements NotePreviewScreenCoordinator {
  const NotePreviewScreenCoordinatorImpl();

  @override
  void onCreateNoteRoute(BuildContext context) => newNote(context);

  @override
  FutureOr<dynamic> onNoteEditRoute(
    BuildContext context, {
    required String noteId,
  }) {
    final router = GoRouter.of(context);

    return router.push(
      '${AppRouterPath.home}/${AppRouterPath.editNote}',
      extra: PathParams(id: noteId).toJson(),
    );
  }

  @override
  FutureOr<dynamic> onRawEventRoute(
    BuildContext context, {
    required String eventId,
  }) {
    final router = GoRouter.of(context);
    const path =
        '${AppRouterPath.home}/${AppRouterPath.editNote}/${AppRouterPath.rawEventDetails}';

    return router.push(
      path,
      extra: PathParamsEventId(eventId: eventId).toJson(),
    );
  }
}
