import 'package:equatable/equatable.dart';

sealed class NotesListEvent extends Equatable {
  const NotesListEvent();

  const factory NotesListEvent.initial() = InitialEvent;
  const factory NotesListEvent.getNotes() = GetNotesEvent;
  const factory NotesListEvent.error({required Object error}) = ErrorEvent;

  @override
  List<Object?> get props => const [];
}

final class InitialEvent extends NotesListEvent {
  const InitialEvent();
}

final class GetNotesEvent extends NotesListEvent {
  const GetNotesEvent();
}

final class ErrorEvent extends NotesListEvent {
  final Object error;
  const ErrorEvent({required this.error});
  @override
  List<Object?> get props => [error];
}
