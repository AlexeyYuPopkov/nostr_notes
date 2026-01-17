import 'package:equatable/equatable.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/core/tools/optional_box.dart';

final class EditRawNoteData extends Equatable {
  final OptionalBox<Note> initialNote;
  final bool hasChanges;

  const EditRawNoteData._({
    required this.initialNote,
    required this.hasChanges,
  });

  factory EditRawNoteData.initial() {
    return const EditRawNoteData._(
      initialNote: OptionalBox(null),
      hasChanges: false,
    );
  }

  @override
  List<Object?> get props => [initialNote, hasChanges];

  EditRawNoteData copyWith({OptionalBox<Note>? initialNote, bool? hasChanges}) {
    return EditRawNoteData._(
      initialNote: initialNote ?? this.initialNote,
      hasChanges: hasChanges ?? this.hasChanges,
    );
  }
}
