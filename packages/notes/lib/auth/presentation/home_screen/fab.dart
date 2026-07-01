import 'package:flutter/material.dart';
import 'package:nostr_notes/l10n/localization.dart';

final class Fab extends StatelessWidget {
  final VoidCallback? onNewNote;
  const Fab({super.key, required this.onNewNote});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'fab_new_note',
      tooltip: context.l10n.notesListNewNoteTooltip,
      onPressed: onNewNote,
      isExtended: true,
      child: const Icon(Icons.add),
    );
  }


}
