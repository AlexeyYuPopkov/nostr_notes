import 'package:flutter/material.dart';
import 'package:nostr_notes/auth/note/note_screen.dart';
import 'package:nostr_notes/auth/settings/settings_screen.dart';

final class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

final class _HomeScreenState extends State<HomeScreen> {
  int? selectedIndex;
  final items = List<String>.generate(20, (i) => 'Item $i');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Builder(builder: (context) {
        return FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () => _onOpenDrawer(context),
        );
      }),
      endDrawer: const SettingsScreen(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 600) {
            return Row(
              children: [
                SizedBox(
                  width: 300,
                  child: _buildList(context),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: selectedIndex == null
                      ? const Center(child: Text('Выберите элемент'))
                      : const NoteScreen(),
                ),
              ],
            );
          }
          // Mobile: only list, details via Navigator
          return _buildList(context, isMobile: true);
        },
      ),
    );
  }

  void _onOpenDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  Widget _buildList(BuildContext context, {bool isMobile = false}) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(items[index]),
        selected: selectedIndex == index,
        onTap: () {
          if (isMobile) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const NoteScreen(),
              ),
            );
          } else {
            setState(() => selectedIndex = index);
          }
        },
      ),
    );
  }
}
