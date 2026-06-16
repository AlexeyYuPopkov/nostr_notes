part of 'note_preview_screen.dart';

mixin _ExportNoteHelper {
  Future<void> willExportNote(BuildContext context) async {
    context.read<NotePreviewBloc>().add(
      const NotePreviewEvent.willExportNote(),
    );
  }

  Future<void> onExportNote(BuildContext context) async {
    final result = await showDialog<ExportPasswordDialogResult>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const ExportPasswordDialog(),
    );

    if (result == null || !context.mounted) {
      return;
    }

    context.read<NotePreviewBloc>().add(
      NotePreviewEvent.exportNote(
        password: result.password,
        fileName: result.fileName,
      ),
    );
  }
}
