import 'package:equatable/equatable.dart';

sealed class NoteScreenEvent extends Equatable {
  const NoteScreenEvent();

  const factory NoteScreenEvent.initial() = InitialEvent;
  const factory NoteScreenEvent.didChangeText(String text) = DidChangeTextEvent;
  const factory NoteScreenEvent.saveNote() = SaveNoteEvent;

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
