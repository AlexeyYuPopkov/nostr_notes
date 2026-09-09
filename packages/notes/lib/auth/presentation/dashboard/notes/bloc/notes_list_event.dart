import 'package:equatable/equatable.dart';
import 'package:nostr_notes/auth/domain/model/label.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';

sealed class NotesListEvent extends Equatable {
  const NotesListEvent();

  const factory NotesListEvent.initial({bool showShimmers}) = InitialEvent;
  const factory NotesListEvent.getNotes({required List<Note> notes}) =
      GetNotesEvent;
  const factory NotesListEvent.refresh() = RefreshEvent;
  const factory NotesListEvent.error({required Object error}) = ErrorEvent;
  const factory NotesListEvent.deleteNote(Note note) = DeleteNoteEvent;

  const factory NotesListEvent.assignLabels({
    required Note note,
    required List<CategoryType> labels,
  }) = AssignLabelsEvent;

  const factory NotesListEvent.search(String query) = SearchNotesEvent;

  /// Replaces the active folder filter wholesale — the picker always hands
  /// back the complete selection, so there's no add/remove pair to keep in
  /// sync.
  const factory NotesListEvent.setFolderFilter(Set<CategoryType> folders) =
      SetFolderFilterEvent;

  @override
  List<Object?> get props => const [];
}

final class InitialEvent extends NotesListEvent {
  final bool showShimmers;
  const InitialEvent({this.showShimmers = true});
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

final class SearchNotesEvent extends NotesListEvent {
  final String query;
  const SearchNotesEvent(this.query);
  @override
  List<Object?> get props => [query];
}

final class SetFolderFilterEvent extends NotesListEvent {
  final Set<CategoryType> folders;
  const SetFolderFilterEvent(this.folders);
  @override
  List<Object?> get props => [folders];
}
