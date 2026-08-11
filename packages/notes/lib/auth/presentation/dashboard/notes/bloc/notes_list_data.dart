import 'package:equatable/equatable.dart';
import 'package:nostr_notes/auth/domain/model/label.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/common/presentation/formatters/date_group.dart';


final class NotesListData extends Equatable {
  /// Full, decrypted set of the user's notes.
  final List<Note> allNotes;

  /// Subset of [allNotes] matching [searchString] and [folderFilter]. Only
  /// meaningful while [isFiltering] is true.
  final List<Note> filtered;

  /// Current notes-list search query (empty = no active search).
  final String searchString;

  /// Folders the list is currently narrowed to (empty = no filter). A note
  /// matches if it carries a label for any folder in this set (OR
  /// semantics) — see `NotesListBloc._visibleNotes`.
  final Set<CategoryType> folderFilter;

  final List<NotesListSection> sections;

  const NotesListData._({
    required this.allNotes,
    required this.filtered,
    required this.searchString,
    required this.folderFilter,
    required this.sections,
  });

  /// Notes to display: the filtered subset while a search or folder filter
  /// is active, otherwise all.
  List<Note> get notes => isFiltering ? filtered : allNotes;

  bool get isFiltering => searchString.trim().isNotEmpty || folderFilter.isNotEmpty;

  factory NotesListData.initial() {
    return const NotesListData._(
      allNotes: [],
      filtered: [],
      searchString: '',
      folderFilter: {},
      sections: [],
    );
  }

  @override
  List<Object?> get props => [
    allNotes,
    filtered,
    searchString,
    folderFilter,
    sections,
  ];

  NotesListData copyWith({
    List<Note>? allNotes,
    List<Note>? filtered,
    String? searchString,
    Set<CategoryType>? folderFilter,
    List<NotesListSection>? sections,
  }) {
    return NotesListData._(
      allNotes: allNotes ?? this.allNotes,
      filtered: filtered ?? this.filtered,
      searchString: searchString ?? this.searchString,
      folderFilter: folderFilter ?? this.folderFilter,
      sections: sections ?? this.sections,
    );
  }
}
