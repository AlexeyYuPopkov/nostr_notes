import 'package:equatable/equatable.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/core/tools/optional_box.dart';

final class MarkdownEditNoteData extends Equatable {
  final OptionalBox<Note> initialNote;
  final String currentText;
  final bool hasChanges;

  const MarkdownEditNoteData._({
    required this.initialNote,
    required this.currentText,
    required this.hasChanges,
  });

  factory MarkdownEditNoteData.initial() {
    return const MarkdownEditNoteData._(
      initialNote: OptionalBox(null),
      currentText: '',
      hasChanges: false,
    );
  }

  @override
  List<Object?> get props => [initialNote, currentText, hasChanges];

  MarkdownEditNoteData copyWith({
    OptionalBox<Note>? initialNote,
    String? currentText,
    bool? hasChanges,
  }) {
    return MarkdownEditNoteData._(
      initialNote: initialNote ?? this.initialNote,
      currentText: currentText ?? this.currentText,
      hasChanges: hasChanges ?? this.hasChanges,
    );
  }
}
