import 'package:equatable/equatable.dart';
import 'package:nostr_notes/auth/domain/model/label.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/auth/presentation/notes_list/tabs/notes_list_tab.dart';

sealed class NotesListEvent extends Equatable {
  const NotesListEvent();

  const factory NotesListEvent.initial() = InitialEvent;
  const factory NotesListEvent.getNotes({required List<Note> notes}) =
      GetNotesEvent;
  const factory NotesListEvent.refresh() = RefreshEvent;
  const factory NotesListEvent.error({required Object error}) = ErrorEvent;
  const factory NotesListEvent.deleteNote(Note note) = DeleteNoteEvent;

  const factory NotesListEvent.assignLabels({
    required Note note,
    required List<CategoryType> labels,
  }) = AssignLabelsEvent;

  const factory NotesListEvent.selectFolder(NotesListTab tab) =
      SelectFolderEvent;

  @override
  List<Object?> get props => const [];
}

final class InitialEvent extends NotesListEvent {
  const InitialEvent();
}

final class GetNotesEvent extends NotesListEvent {
  final List<Note> notes;
  const GetNotesEvent({required this.notes});

  @override
  List<Object?> get props => [notes];
}

final class RefreshEvent extends NotesListEvent {
  const RefreshEvent();
}

final class ErrorEvent extends NotesListEvent {
  final Object error;
  const ErrorEvent({required this.error});
  @override
  List<Object?> get props => [error];
}

final class DeleteNoteEvent extends NotesListEvent {
  final Note note;
  const DeleteNoteEvent(this.note);
  @override
  List<Object?> get props => [note];
}

final class AssignLabelsEvent extends NotesListEvent {
  final Note note;
  final List<CategoryType> labels;
  const AssignLabelsEvent({required this.note, required this.labels});
  @override
  List<Object?> get props => [note, labels];
}

final class SelectFolderEvent extends NotesListEvent {
  final NotesListTab tab;
  const SelectFolderEvent(this.tab);
  @override
  List<Object?> get props => [tab];
}
