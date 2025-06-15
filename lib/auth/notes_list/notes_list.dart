import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nostr_notes/app/router/app_router_path.dart';
import 'package:nostr_notes/app/sizes.dart';

final class NotesList extends StatelessWidget {
  final List<String> items;
  final int? selectedIndex;

  final ValueChanged<int> onTap;
  const NotesList({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Заметки'),
        actions: const [_NewNote()],
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(items[index]),
          selected: selectedIndex == index,
          onTap: () => onTap(index),
        ),
      ),
    );
  }
}

final class _NewNote extends StatelessWidget {
  const _NewNote();

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      child: const Icon(
        Icons.edit_note,
        size: Sizes.icon,
      ),
      onPressed: () => _onNewNote(context),
    );
  }

  void _onNewNote(BuildContext context) {
    GoRouter.of(context).push(AppRouterPath.note);
  }
}
