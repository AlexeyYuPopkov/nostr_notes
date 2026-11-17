import 'package:common/app/theme/sizes.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/auth/presentation/dashboard/bloc/dashboard_event.dart';

import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_state.dart' as dashboard_state;
import '../notes_list_tab.dart';
import '../widgets/common_toolbar_tabs_widget.dart';

final class NotesListScreenToolbar extends StatelessWidget {
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
          child: CommonToolbarTabsWidget(
            currentTab: tab,
            tabs: NotesListTab.tabs,
            onChangeTab: (context, _, tab) => _onChangeTab(context, tab: tab),
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
}
