import 'package:common/app/theme/sizes.dart';
import 'package:flutter/cupertino.dart';
import 'package:nostr_notes/auth/presentation/model/path_params.dart';
import 'package:nostr_notes/auth/presentation/note_screen/edit_note_markdown_screen/edit_note_markdown_screen.dart';
import 'package:nostr_notes/auth/presentation/note_screen/note_preview_screen/note_preview_screen.dart';

/// Preview and editor for one note, as a single destination: switching
/// between them is local state rather than navigation, mirroring how a login
/// item toggles its own readonly flag.
///
/// A note with no [pathParams] does not exist yet, so it opens straight into
/// the editor and settles into preview once the first save returns its id.
final class NoteScreen extends StatefulWidget {
  final PathParams? pathParams;
  final NotePreviewScreenCoordinator coordinator;

  const NoteScreen({super.key, this.pathParams, required this.coordinator});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

final class _NoteScreenState extends State<NoteScreen> {
  late PathParams? _params = widget.pathParams;
  late bool _isEditing = _params == null;

  void _onEdit() => setState(() => _isEditing = true);

  void _onSaved(String noteId) {
    setState(() {
      _params = PathParams(id: noteId);
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final params = _params;

    final returnsToPreview = _isEditing && params != null;

    return PopScope(
      canPop: !returnsToPreview,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        setState(() => _isEditing = false);
      },
      child: AnimatedSwitcher(
        duration: AppDurations.medium,
        child: _isEditing || params == null
            ? EditMarkdownNoteScreen(
                key: ValueKey('edit:${params?.id ?? ''}'),
                pathParams: params,
                onSaved: _onSaved,
              )
            : NotePreviewScreen(
                key: ValueKey('preview:${params.id}'),
                pathParams: params,
                coordinator: widget.coordinator,
                onEdit: _onEdit,
              ),
      ),
    );
  }
}
