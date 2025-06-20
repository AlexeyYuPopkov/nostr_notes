import 'package:equatable/equatable.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';

sealed class NotesListEvent extends Equatable {
  const NotesListEvent();

  const factory NotesListEvent.initial() = InitialEvent;
  const factory NotesListEvent.notes({required List<NoteBase> notes}) =
      NotesEvent;
  const factory NotesListEvent.error({required Object error}) = ErrorEvent;

  @override
  List<Object?> get props => const [];
}

final class InitialEvent extends NotesListEvent {
  const InitialEvent();
}

final class NotesEvent extends NotesListEvent {
  final List<NoteBase> notes;
  const NotesEvent({required this.notes});
  @override
  List<Object?> get props => [notes];
}

final class ErrorEvent extends NotesListEvent {
  final Object error;
  const ErrorEvent({required this.error});
  @override
  List<Object?> get props => [error];
}
