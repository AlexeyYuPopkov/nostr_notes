import 'package:equatable/equatable.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/core/tools/optional_box.dart';

final class NotePreviewData extends Equatable {
  final OptionalBox<Note> note;
  const NotePreviewData._({required this.note});

  factory NotePreviewData.initial() {
    return const NotePreviewData._(note: OptionalBox(null));
  }

  @override
  List<Object?> get props => [note];

  NotePreviewData copyWith({OptionalBox<Note>? note}) {
    return NotePreviewData._(note: note ?? this.note);
  }
}
