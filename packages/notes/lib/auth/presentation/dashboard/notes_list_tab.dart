import 'package:common/app/theme/sizes.dart';
import 'package:common/presentation/tools/section_scroll_vm.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/app/app_config.dart';
import 'package:nostr_notes/auth/presentation/dashboard/accs/accs_tab_content.dart';
import 'package:nostr_notes/auth/presentation/dashboard/notes/bloc/notes_list_bloc.dart';
import 'package:nostr_notes/auth/presentation/dashboard/notes/bloc/notes_list_state.dart';
import 'package:nostr_notes/auth/presentation/dashboard/notes/notes_tab_content.dart';
import 'package:nostr_notes/auth/presentation/dashboard/notes_list.dart';
import 'package:nostr_notes/auth/presentation/dashboard/widgets/common_toolbar_tabs_widget.dart';
import 'package:nostr_notes/auth/presentation/dashboard/widgets/notes_search_field.dart';
import 'package:nostr_notes/l10n/localization.dart';

import 'accs/accs_tab_header.dart';
import 'notes/bloc/notes_list_event.dart';

const double kNotesListHeaderWithoutSearch = Sizes.indent4x + Sizes.indent2x;
const double _kSearchFieldHeight = 52.0;
const double kNotesListHeaderWithSearch =
    kNotesListHeaderWithoutSearch + _kSearchFieldHeight;
// The folder-filter chip row (see FolderFilterChipsRow) sits between the
// toolbar and the search field whenever a filter is active.
const double _kFilterChipRowHeight = 44.0;
const double kNotesListHeaderWithSearchAndFilter =
    kNotesListHeaderWithSearch + _kFilterChipRowHeight;

sealed class NotesListTab extends Equatable
    implements CommonToolbarTabsWidgetTab {
  static const List<NotesListTab> tabs = [
    NotesListTab.notes(),
    if (FeatureFlags.kEnableAccsTab) NotesListTab.accs(),
  ];

  int get index;
  const NotesListTab();

  const factory NotesListTab.notes() = NotesNotesTab;
  const factory NotesListTab.accs() = AccsTab;

  Widget build(BuildContext context, {required TabParams params});

  Widget buildHeader(BuildContext context, {required HeaderParams params});
}

final class NotesNotesTab extends NotesListTab {
  const NotesNotesTab();

  @override
  int get index => 0;

  @override
  Widget build(BuildContext context, {required TabParams params}) {
    return BlocBuilder<NotesListBloc, NotesListState>(
      builder: (context, state) {
        return NotesTabContent(
          selectedNoteDTag: params.selectedNoteDTag,
          isLoading: state is LoadingState,
          sections: state.data.sections,
          searchQuery: state.data.searchString,
          hasAnyNotes: state.data.allNotes.isNotEmpty,
          showFolderFilterChips: state.data.folderFilter.isNotEmpty,
          onTap: (note) =>
              params.coordinator.onNotePreviewRoute(noteId: note.dTag, context),
          scrollSectionsVm: params._scrollSectionsVm,
        );
      },
    );
  }

  @override
  List<Object?> get props => [];

  @override
  String getLocalizedTitle(BuildContext context) =>
      context.l10n.notesListTabNotes;

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

final class AccsTab extends NotesListTab {
  const AccsTab();

  @override
  int get index => 1;

  @override
  Widget build(BuildContext context, {required TabParams params}) {
    return AccsTabContent(
      onDetails: (item) => params.coordinator.onLoginItemDetails(
        context,
        item: item,
        readonly: true,
      ),
    );
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

  final NotesListCoordinator coordinator;
  final SectionScrollVm _scrollSectionsVm;

  const TabParams({
    required this.selectedNoteDTag,
    required this.coordinator,
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
