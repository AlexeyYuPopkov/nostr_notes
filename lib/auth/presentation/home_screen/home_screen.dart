import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nostr_notes/app/router/app_router_path.dart';
import 'package:nostr_notes/app/sizes.dart';
import 'package:nostr_notes/auth/presentation/model/path_params.dart';
import 'package:nostr_notes/auth/presentation/settings/settings_screen.dart';

import '../notes_list/notes_list.dart';

final class HomeScreen extends StatelessWidget {
  final Widget child;
  final bool hasNote;

  const HomeScreen({super.key, required this.child, required this.hasNote});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 600;

        final desktopSideAreaWidth = constraints.maxWidth * 0.3;

        return Scaffold(
          floatingActionButton: Builder(
            builder: (context) {
              return FloatingActionButton(
                child: const Icon(Icons.add),
                onPressed: () => _onOpenDrawer(context),
              );
            },
          ),
          endDrawer: SizedBox(
            width: isDesktop ? desktopSideAreaWidth : double.infinity,
            child: const SettingsScreen(),
          ),
          body: isDesktop
              ? Row(
                  children: [
                    SizedBox(
                      width: desktopSideAreaWidth,
                      child: NotesList(
                        selectedNoteDTag: null,
                        onTap: (note) {
                          GoRouter.of(context).pushReplacementNamed(
                            AppRouterName.note,
                            queryParameters: PathParams(id: note.dTag).toJson(),
                          );
                        },
                      ),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(child: child),
                  ],
                )
              : Stack(
                  children: [
                    NotesList(
                      selectedNoteDTag: null,
                      onTap: (note) {
                        GoRouter.of(context).pushReplacementNamed(
                          AppRouterName.note,
                          queryParameters: PathParams(id: note.dTag).toJson(),
                        );
                      },
                    ),
                    AnimatedSlide(
                      offset: hasNote
                          ? const Offset(0.0, 0.0)
                          : const Offset(1.0, 0.0),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: hasNote
                          ? child
                          : Scaffold(
                              appBar: AppBar(
                                leading: BackButton(onPressed: () {}),
                              ),
                            ),
                    ),
                  ],
                ),
          // }
        );
      },
    );
  }

  void _onOpenDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }
}

final class NewNotePromptPlaceholder extends StatelessWidget {
  const NewNotePromptPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Sizes.indent2x),
      child: Center(
        child: Text(
          'Выберите заметку или создайте новую',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}
