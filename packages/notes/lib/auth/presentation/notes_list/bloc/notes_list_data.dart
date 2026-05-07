import 'package:equatable/equatable.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/common/presentation/formatters/date_group.dart';

import '../tabs/notes_list_tab.dart';

final class NotesListData extends Equatable {
  final List<Note> notes;
  final List<NotesListSection> sections;
  final NotesListTab tab;

  const NotesListData._({
    required this.notes,
    required this.sections,
    required this.tab,
  });

  factory NotesListData.initial() {
    return const NotesListData._(
      notes: [],
      sections: [],
      tab: NotesListTab.all(),
    );
  }

  @override
  List<Object?> get props => [notes, sections, tab];

  NotesListData copyWith({
    List<Note>? notes,
    List<NotesListSection>? sections,
    NotesListTab? tab,
  }) {
    return NotesListData._(
      notes: notes ?? this.notes,
      sections: sections ?? this.sections,
      tab: tab ?? this.tab,
    );
  }
}
