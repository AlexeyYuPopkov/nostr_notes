import 'package:equatable/equatable.dart';

sealed class NoteScreenEvent extends Equatable {
  const NoteScreenEvent();

  const factory NoteScreenEvent.initial() = InitialEvent;
  const factory NoteScreenEvent.didChangeText(String text) = DidChangeTextEvent;
  const factory NoteScreenEvent.saveNote() = SaveNoteEvent;
  const factory NoteScreenEvent.changeEditMode(bool editMode) =
      ChangeEditModeEvent;

  @override
  List<Object?> get props => const [];
}

final class InitialEvent extends NoteScreenEvent {
  const InitialEvent();
}

final class DidChangeTextEvent extends NoteScreenEvent {
  final String text;

  const DidChangeTextEvent(this.text);

  @override
  List<Object?> get props => [text];
}

final class SaveNoteEvent extends NoteScreenEvent {
  const SaveNoteEvent();
}

final class ChangeEditModeEvent extends NoteScreenEvent {
  final bool editMode;

  const ChangeEditModeEvent(this.editMode);
}
