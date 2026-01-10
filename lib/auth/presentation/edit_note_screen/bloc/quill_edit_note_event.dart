import 'package:equatable/equatable.dart';

sealed class QuillEditNoteEvent extends Equatable {
  const QuillEditNoteEvent();

  const factory QuillEditNoteEvent.initial() = InitialEvent;

  const factory QuillEditNoteEvent.save() = SaveEvent;

  const factory QuillEditNoteEvent.shouldCheckChanges() = ShouldCheckChanges;

  @override
  List<Object?> get props => const [];
}

final class InitialEvent extends QuillEditNoteEvent {
  const InitialEvent();
}

final class SaveEvent extends QuillEditNoteEvent {
  const SaveEvent();
}

final class ShouldCheckChanges extends QuillEditNoteEvent {
  const ShouldCheckChanges();
}
