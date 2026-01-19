import 'package:equatable/equatable.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/core/tools/optional_box.dart';

final class QuillEditNoteData extends Equatable {
  final OptionalBox<Note> initialNote;
  final bool hasChanges;

  const QuillEditNoteData._({
    required this.initialNote,
    required this.hasChanges,
  });

  factory QuillEditNoteData.initial() {
    return const QuillEditNoteData._(
      initialNote: OptionalBox(null),
      hasChanges: false,
    );
  }

  @override
  List<Object?> get props => [initialNote, hasChanges];

  QuillEditNoteData copyWith({
    OptionalBox<Note>? initialNote,
    bool? hasChanges,
  }) {
    return QuillEditNoteData._(
      initialNote: initialNote ?? this.initialNote,
      hasChanges: hasChanges ?? this.hasChanges,
    );
  }
}
