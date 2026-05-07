import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/auth/presentation/notes_list/bloc/notes_list_bloc.dart';
import 'package:nostr_notes/auth/presentation/notes_list/bloc/notes_list_state.dart';
import 'package:nostr_notes/auth/presentation/notes_list/tabs/all_tab_content.dart';
import 'package:nostr_notes/auth/presentation/notes_list/widgets/common_toolbar_tabs_widget.dart';
import 'package:nostr_notes/l10n/localization.dart';

import 'folders_tab_content.dart';

sealed class NotesListTab extends Equatable
    implements CommonToolbarTabsWidgetTab {
  static const List<NotesListTab> tabs = [
    NotesListTab.all(),
    NotesListTab.folders(),
  ];

  int get index;
  const NotesListTab();

  const factory NotesListTab.all() = AllNotesTab;
  const factory NotesListTab.folders() = FoldersTab;

  Widget build(BuildContext context, {required TabParams params});
}

final class TabParams extends Equatable {
  final String? selectedNoteDTag;
  final ValueChanged<Note> onTap;

  const TabParams({required this.selectedNoteDTag, required this.onTap});

  @override
  List<Object?> get props => [selectedNoteDTag];
}

final class AllNotesTab extends NotesListTab {
  const AllNotesTab();

  @override
  int get index => 0;

  @override
  Widget build(BuildContext context, {required TabParams params}) {
    return BlocBuilder<NotesListBloc, NotesListState>(
      builder: (context, state) {
        return AllTabContent(
          selectedNoteDTag: params.selectedNoteDTag,
          isLoading: state is LoadingState,
          sections: state.data.sections,
          onTap: params.onTap,
        );
      },
    );
  }

  @override
  List<Object?> get props => [];

  @override
  String getLocalizedTitle(BuildContext context) =>
      context.l10n.notesListTabAll;
}

final class FoldersTab extends NotesListTab {
  const FoldersTab();

  @override
  int get index => 1;

  @override
  Widget build(BuildContext context, {required TabParams params}) {
    return BlocBuilder<NotesListBloc, NotesListState>(
      builder: (context, state) {
        return FoldersTabContent(
          vm: context.read<NotesListBloc>().foldersVm,
          selectedNoteDTag: params.selectedNoteDTag,
          isLoading: state is LoadingState,
          onTap: params.onTap,
        );
      },
    );
  }

  @override
  List<Object?> get props => [];

  @override
  String getLocalizedTitle(BuildContext context) =>
      context.l10n.notesListTabFolders;
}
