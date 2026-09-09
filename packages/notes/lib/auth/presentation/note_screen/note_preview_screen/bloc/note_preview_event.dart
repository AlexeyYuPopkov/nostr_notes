import 'package:equatable/equatable.dart';
import 'package:nostr_notes/auth/domain/model/label.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';

sealed class NotePreviewEvent extends Equatable {
  const NotePreviewEvent();

  const factory NotePreviewEvent.initial() = InitialEvent;
  const factory NotePreviewEvent.error({required Object error}) = ErrorEvent;
  const factory NotePreviewEvent.noteUpdated(Note note) = NoteUpdatedEvent;
  const factory NotePreviewEvent.refresh() = RefreshEvent;
  const factory NotePreviewEvent.assignLabels({
    required Note note,
    required List<CategoryType> labels,
  }) = AssignLabelsEvent;

  const factory NotePreviewEvent.willExportNote() = WillExportNoteEvent;

  const factory NotePreviewEvent.exportNote({
    required String password,
    String? fileName,
  }) = ExportNoteEvent;

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

final class RefreshEvent extends NotePreviewEvent {
  const RefreshEvent();
}

final class AssignLabelsEvent extends NotePreviewEvent {
  final Note note;
  final List<CategoryType> labels;
  const AssignLabelsEvent({required this.note, required this.labels});

  @override
  List<Object?> get props => [note, labels];
}

final class WillExportNoteEvent extends NotePreviewEvent {
  const WillExportNoteEvent();
}

final class ExportNoteEvent extends NotePreviewEvent {
  final String password;
  final String? fileName;
  const ExportNoteEvent({required this.password, this.fileName});

  @override
  List<Object?> get props => [password, fileName];
}
