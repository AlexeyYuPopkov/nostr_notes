import 'package:equatable/equatable.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/core/tools/optional_box.dart';

final class NoteScreenData extends Equatable {
  final OptionalBox<Note> initialNote;
  final String text;
  final bool editMode;

  const NoteScreenData._(
      {required this.initialNote, required this.text, required this.editMode});

  factory NoteScreenData.initial() {
    return const NoteScreenData._(
      initialNote: OptionalBox(null),
      text: '',
      editMode: false,
    );
  }

  @override
  List<Object?> get props => [initialNote, text, editMode];

  bool get isChanged => (initialNote.value?.content ?? '') != text;

  NoteScreenData copyWith({
    OptionalBox<Note>? initialNote,
    String? text,
    bool? editMode,
  }) {
    return NoteScreenData._(
      initialNote: initialNote ?? this.initialNote,
      text: text ?? this.text,
      editMode: editMode ?? this.editMode,
    );
  }
}
