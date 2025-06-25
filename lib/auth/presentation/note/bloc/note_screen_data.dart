import 'package:equatable/equatable.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/core/tools/optional_box.dart';

final class NoteScreenData extends Equatable {
  final OptionalBox<Note> initialNote;
  final String text;

  const NoteScreenData._({required this.initialNote, required this.text});

  factory NoteScreenData.initial() {
    return const NoteScreenData._(
      initialNote: OptionalBox(null),
      text: '',
    );
  }

  @override
  List<Object?> get props => [initialNote, text];

  bool get isChanged => (initialNote.value?.content ?? '') != text;

  NoteScreenData copyWith({
    OptionalBox<Note>? initialNote,
    String? text,
  }) {
    return NoteScreenData._(
      initialNote: initialNote ?? this.initialNote,
      text: text ?? this.text,
    );
  }
}
