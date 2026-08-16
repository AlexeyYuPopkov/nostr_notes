import 'package:equatable/equatable.dart';
import 'package:nostr_notes/auth/presentation/dashboard/notes_list_tab.dart';

final class DashboardData extends Equatable {
  final NotesListTab tab;
  const DashboardData._({required this.tab});

  factory DashboardData.initial() {
    return const DashboardData._(tab: NotesListTab.notes());
  }

  @override
  List<Object?> get props => [tab];

  DashboardData copyWith({NotesListTab? tab}) {
    return DashboardData._(tab: tab ?? this.tab);
  }
}
