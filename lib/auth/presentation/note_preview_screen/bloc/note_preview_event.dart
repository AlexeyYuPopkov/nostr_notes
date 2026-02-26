import 'package:equatable/equatable.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';

sealed class NotePreviewEvent extends Equatable {
  const NotePreviewEvent();

  const factory NotePreviewEvent.initial() = InitialEvent;
  const factory NotePreviewEvent.error({required Object error}) = ErrorEvent;
  const factory NotePreviewEvent.noteUpdated(Note note) = NoteUpdatedEvent;

  @override
  @override
  List<Object?> get props => const [];
}

final class InitialEvent extends NotePreviewEvent {
  const InitialEvent();
}

final class ErrorEvent extends NotePreviewEvent {
  final Object error;
  const ErrorEvent({required this.error});
}

final class NoteUpdatedEvent extends NotePreviewEvent {
  final Note note;
  const NoteUpdatedEvent(this.note);
}
