import 'package:common/app/theme/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/auth/presentation/dashboard/bloc/dashboard_event.dart';
import 'package:nostr_notes/auth/presentation/dashboard/notes/bloc/notes_list_event.dart';
import 'package:nostr_notes/auth/presentation/dashboard/widgets/folder_filter_picker.dart';

import '../../../domain/model/label.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_state.dart' as dashboard_state;
import '../notes/bloc/notes_list_bloc.dart';
import '../notes/bloc/notes_list_state.dart';
import '../notes_list_tab.dart';
import '../widgets/common_toolbar_tabs_widget.dart';

final class NotesListScreenToolbar extends StatelessWidget
    with FolderFilterPickerHelper {
  const NotesListScreenToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      DashboardBloc,
      dashboard_state.DashboardState,
      NotesListTab
    >(
      selector: (state) => state.data.tab,
      builder: (context, tab) {
        return Padding(
          padding: const EdgeInsets.only(top: Sizes.indent),
          child: Row(
            children: [
              Expanded(
                child: CommonToolbarTabsWidget(
                  currentTab: tab,
                  tabs: NotesListTab.tabs,
                  onChangeTab: (context, _, tab) =>
                      _onChangeTab(context, tab: tab),
                ),
              ),
              // Filtering only applies to notes — hidden on every other tab.
              if (tab is NotesNotesTab)
                Padding(
                  padding: const EdgeInsets.only(right: Sizes.indent),
                  child:
                      BlocSelector<
                        NotesListBloc,
                        NotesListState,
                        Set<CategoryType>
                      >(
                        selector: (state) => state.data.folderFilter,
                        builder: (context, folderFilter) {
                          return FolderFilterButton(
                            selectedCount: folderFilter.length,
                            onTap: () =>
                                _onFilterTap(context, selected: folderFilter),
                          );
                        },
                      ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _onChangeTab(
    BuildContext context, {
    required CommonToolbarTabsWidgetTab tab,
  }) {
    context.read<DashboardBloc>().add(
      DashboardEvent.selectTab(tab as NotesListTab),
    );
  }

  void _onFilterTap(
    BuildContext context, {
    required Set<CategoryType> selected,
  }) {
    final bloc = context.read<NotesListBloc>();
    showFolderFilterPicker(
      context,
      folderCounts: bloc.folderCounts,
      selected: selected,
      onApply: (folders) => bloc.add(NotesListEvent.setFolderFilter(folders)),
    );
  }
}
