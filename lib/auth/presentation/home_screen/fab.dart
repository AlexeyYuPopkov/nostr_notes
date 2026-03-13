import 'package:flutter/material.dart';
import 'package:nostr_notes/app/router/app_route/route_handler.dart';
import 'package:nostr_notes/app/router/note_router.dart';
import 'package:nostr_notes/app/sizes.dart';

final class Fab extends StatelessWidget {
  const Fab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'fab_new_note',
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Sizes.radiusVariant),
      ),
      backgroundColor: Colors.white,
      onPressed: () => _onNewNote(context),
      isExtended: true,
      child: const Icon(Icons.add),
    );
  }

  void _onNewNote(BuildContext context) {
    RouteHandler.of(context)?.onRoute(const NewNoteRoute(), context);
  }
}
