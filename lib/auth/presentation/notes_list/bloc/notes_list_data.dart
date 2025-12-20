import 'package:equatable/equatable.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';

final class NotesListData extends Equatable {
  final List<NoteBase> notes;
  const NotesListData._({required this.notes});

  factory NotesListData.initial() {
    return const NotesListData._(notes: []);
  }

  @override
  List<Object?> get props => [notes];

  NotesListData copyWith({List<NoteBase>? notes}) {
    return NotesListData._(notes: notes ?? this.notes);
  }
}
