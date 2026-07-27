import 'package:equatable/equatable.dart';
import 'package:nostr_notes/auth/presentation/dashboard/notes_list_tab.dart';

sealed class DashboardEvent extends Equatable {
  const DashboardEvent();

  const factory DashboardEvent.initial() = InitialEvent;
  const factory DashboardEvent.selectTab(NotesListTab tab) = SelectTabEvent;
  const factory DashboardEvent.refresh() = RefreshEvent;

  @override
  List<Object?> get props => const [];
}

final class InitialEvent extends DashboardEvent {
  const InitialEvent();
}

final class SelectTabEvent extends DashboardEvent {
  final NotesListTab tab;
  const SelectTabEvent(this.tab);
  @override
  List<Object?> get props => [tab];
}

final class RefreshEvent extends DashboardEvent {
  const RefreshEvent();
}
