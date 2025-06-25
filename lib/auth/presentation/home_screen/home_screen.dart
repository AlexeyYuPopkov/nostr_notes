import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nostr_notes/app/router/app_router_path.dart';
import 'package:nostr_notes/auth/presentation/home_screen/bloc/home_screen_bloc.dart';
import 'package:nostr_notes/auth/presentation/home_screen/bloc/home_screen_state.dart';
import 'package:nostr_notes/auth/presentation/model/path_params.dart';
import 'package:nostr_notes/auth/presentation/note/note_screen.dart';
import 'package:nostr_notes/auth/presentation/settings/settings_screen.dart';
import 'package:nostr_notes/common/presentation/dialogs/dialog_helper.dart';

import '../notes_list/notes_list.dart';

final class HomeScreen extends StatelessWidget with DialogHelper {
  const HomeScreen({super.key});

  void _listener(BuildContext context, HomeScreenState state) {
    switch (state) {
      case CommonState():
      case LoadingState():
        break;
      case ErrorState():
        showError(context, error: state.e);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeScreenBloc(),
      child: BlocConsumer<HomeScreenBloc, HomeScreenState>(
        listener: _listener,
        builder: (context, state) {
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
                      const Expanded(
                        child: NoteScreen(),
                      ),
                    ],
                  );
                }
                // Mobile: only list, details via Navigator
                return _buildList(context, isMobile: true);
              },
            ),
          );
        },
      ),
    );
  }

  void _onOpenDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  Widget _buildList(BuildContext context, {bool isMobile = false}) {
    return NotesList(
      // items: const [],
      // selectedIndex: null,
      onTap: (note) {
        if (isMobile) {
          GoRouter.of(context).pushNamed(
            AppRouterName.note,
            queryParameters: PathParams(id: note.dTag).toJson(),
          );
          // Navigator.of(context).push(
          //   MaterialPageRoute(
          //     builder: (_) => const NoteScreen(),
          //   ),
          // );
        } else {
          // setState(() => selectedIndex = index);
        }
      },
    );
  }
}
