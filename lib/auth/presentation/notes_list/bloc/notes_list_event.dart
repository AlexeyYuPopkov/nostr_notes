import 'package:equatable/equatable.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';

sealed class NotesListEvent extends Equatable {
  const NotesListEvent();

  const factory NotesListEvent.initial() = InitialEvent;
  const factory NotesListEvent.getNotes({required List<NoteBase> notes}) =
      GetNotesEvent;
  const factory NotesListEvent.refresh() = RefreshEvent;
  const factory NotesListEvent.error({required Object error}) = ErrorEvent;

  @override
  List<Object?> get props => const [];
}

final class InitialEvent extends NotesListEvent {
  const InitialEvent();
}

final class GetNotesEvent extends NotesListEvent {
  final List<NoteBase> notes;
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
