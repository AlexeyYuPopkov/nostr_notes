import 'package:equatable/equatable.dart';
import 'package:nostr_notes/auth/domain/model/category.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/common/presentation/formatters/date_group.dart';
import 'package:nostr_notes/core/tools/optional_box.dart';

final class NotesListData extends Equatable {
  final List<Note> notes;
  final List<NotesListSection> sections;

  final OptionalBox<CategoryType> selectedCategory;

  const NotesListData._({
    required this.notes,
    required this.sections,
    required this.selectedCategory,
  });

  factory NotesListData.initial() {
    return const NotesListData._(
      notes: [],
      sections: [],
      selectedCategory: OptionalBox(null),
    );
  }

  @override
  List<Object?> get props => [notes, sections, selectedCategory];

  NotesListData copyWith({
    List<Note>? notes,
    List<NotesListSection>? sections,
    OptionalBox<CategoryType>? selectedCategory,
  }) {
    return NotesListData._(
      notes: notes ?? this.notes,
      sections: sections ?? this.sections,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}
