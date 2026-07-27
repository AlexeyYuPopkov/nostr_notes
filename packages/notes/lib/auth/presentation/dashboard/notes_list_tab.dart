import 'package:common/app/theme/sizes.dart';
import 'package:common/presentation/tools/section_scroll_vm.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/app/app_config.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/auth/presentation/dashboard/accs/accs_tab_content.dart';
import 'package:nostr_notes/auth/presentation/dashboard/notes/bloc/notes_list_bloc.dart';
import 'package:nostr_notes/auth/presentation/dashboard/notes/bloc/notes_list_state.dart';
import 'package:nostr_notes/auth/presentation/dashboard/folders/widgets/folder_back_button.dart';
import 'package:nostr_notes/auth/presentation/dashboard/notes/all_tab_content.dart';
import 'package:nostr_notes/auth/presentation/dashboard/widgets/common_toolbar_tabs_widget.dart';
import 'package:nostr_notes/auth/presentation/dashboard/widgets/notes_search_field.dart';
import 'package:nostr_notes/l10n/localization.dart';

import 'accs/accs_tab_header.dart';
import 'notes/bloc/notes_list_event.dart';
import 'folders/folders_tab_content.dart';

const double kNotesListHeaderWithoutSearch = Sizes.indent4x + Sizes.indent2x;
const double _kSearchFieldHeight = 52.0;
const double kNotesListHeaderWithSearch =
    kNotesListHeaderWithoutSearch + _kSearchFieldHeight;

sealed class NotesListTab extends Equatable
    implements CommonToolbarTabsWidgetTab {
  static const List<NotesListTab> tabs = [
    NotesListTab.all(),
    NotesListTab.folders(),
    if (FeatureFlags.kEnableAccsTab) NotesListTab.accs(),
  ];

  int get index;
  const NotesListTab();

  const factory NotesListTab.all() = AllNotesTab;
  const factory NotesListTab.folders() = FoldersTab;
  const factory NotesListTab.accs() = AccsTab;

  Widget build(BuildContext context, {required TabParams params});

  Widget buildHeader(BuildContext context, {required HeaderParams params});
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
          searchQuery: state.data.searchString,
          hasAnyNotes: state.data.allNotes.isNotEmpty,
          onTap: params.onTap,
          scrollSectionsVm: params._scrollSectionsVm,
        );
      },
    );
  }

  @override
  List<Object?> get props => [];

  @override
  String getLocalizedTitle(BuildContext context) =>
      context.l10n.notesListTabAll;

  @override
  Widget buildHeader(BuildContext context, {required HeaderParams params}) {
    return Padding(
      key: const ValueKey('search'),
      padding: const EdgeInsets.only(
        left: Sizes.indent,
        right: Sizes.indent,
        bottom: Sizes.indent,
      ),
      // Search is cleared on any tab change from inside NotesListBloc itself
      // (subscribed to DashboardBloc.stream), not from this widget — that
      // way the reset survives regardless of which header is mounted.
      child: BlocSelector<NotesListBloc, NotesListState, String>(
        selector: (state) => state.data.searchString,
        builder: (context, str) {
          return NotesSearchField(
            initialQuery: str,
            onChanged: (value) =>
                context.read<NotesListBloc>().add(NotesListEvent.search(value)),
          );
        },
      ),
    );
  }
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
          scrollSectionsVm: params._scrollSectionsVm,
        );
      },
    );
  }

  @override
  List<Object?> get props => [];

  @override
  String getLocalizedTitle(BuildContext context) =>
      context.l10n.notesListTabFolders;

  @override
  Widget buildHeader(BuildContext context, {required HeaderParams params}) {
    return FolderBackButton(scrollVm: params.scrollSectionsVm);
  }
}

final class AccsTab extends NotesListTab {
  const AccsTab();

  @override
  int get index => 2;

  @override
  Widget build(BuildContext context, {required TabParams params}) {
    return const AccsTabContent();
  }

  @override
  List<Object?> get props => [];

  @override
  String getLocalizedTitle(BuildContext context) => context.l10n.accsTabTitle;

  @override
  Widget buildHeader(BuildContext context, {required HeaderParams params}) {
    return AccsTabHeader(params: params);
  }
}

final class TabParams extends Equatable {
  final String? selectedNoteDTag;

  final ValueChanged<Note> onTap;
  final SectionScrollVm _scrollSectionsVm;

  const TabParams({
    required this.selectedNoteDTag,

    required this.onTap,
    required SectionScrollVm scrollSectionsVm,
  }) : _scrollSectionsVm = scrollSectionsVm;

  @override
  List<Object?> get props => [selectedNoteDTag];
}

final class HeaderParams extends Equatable {
  final String searchQuery;
  final SectionScrollVm scrollSectionsVm;

  const HeaderParams({
    required this.searchQuery,
    required this.scrollSectionsVm,
  });

  @override
  List<Object?> get props => [searchQuery];
}
