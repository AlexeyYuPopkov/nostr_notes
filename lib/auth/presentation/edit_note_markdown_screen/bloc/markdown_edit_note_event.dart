import 'package:equatable/equatable.dart';

sealed class MarkdownEditNoteEvent extends Equatable {
  const MarkdownEditNoteEvent();

  const factory MarkdownEditNoteEvent.initial() = InitialEvent;

  const factory MarkdownEditNoteEvent.save() = SaveEvent;

  const factory MarkdownEditNoteEvent.textChanged(String text) =
      TextChangedEvent;

  @override
  List<Object?> get props => const [];
}

final class InitialEvent extends MarkdownEditNoteEvent {
  const InitialEvent();
}

final class SaveEvent extends MarkdownEditNoteEvent {
  const SaveEvent();
}

final class TextChangedEvent extends MarkdownEditNoteEvent {
  final String text;
  const TextChangedEvent(this.text);

  @override
  List<Object?> get props => [text];
}
