import 'package:equatable/equatable.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/common/presentation/formatters/date_group.dart';


final class NotesListData extends Equatable {
  /// Full, decrypted set of the user's notes.
  final List<Note> allNotes;

  /// Subset of [allNotes] matching [searchString]. Only meaningful while
  /// [searchString] is non-empty.
  final List<Note> filtered;

  /// Current notes-list search query (empty = no active search).
  final String searchString;

  final List<NotesListSection> sections;

  const NotesListData._({
    required this.allNotes,
    required this.filtered,
    required this.searchString,
    required this.sections,
  });

  /// Notes to display: the filtered subset while searching, otherwise all.
  List<Note> get notes => searchString.trim().isEmpty ? allNotes : filtered;

  bool get isSearching => searchString.trim().isNotEmpty;

  factory NotesListData.initial() {
    return const NotesListData._(
      allNotes: [],
      filtered: [],
      searchString: '',
      sections: [],
    );
  }

  @override
  List<Object?> get props => [allNotes, filtered, searchString, sections];

  NotesListData copyWith({
    List<Note>? allNotes,
    List<Note>? filtered,
    String? searchString,
    List<NotesListSection>? sections,
  }) {
    return NotesListData._(
      allNotes: allNotes ?? this.allNotes,
      filtered: filtered ?? this.filtered,
      searchString: searchString ?? this.searchString,
      sections: sections ?? this.sections,
    );
  }
}
