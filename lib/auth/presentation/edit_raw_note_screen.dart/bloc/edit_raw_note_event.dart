import 'package:equatable/equatable.dart';

sealed class EditRawNoteEvent extends Equatable {
  const EditRawNoteEvent();

  const factory EditRawNoteEvent.initial() = InitialEvent;

  const factory EditRawNoteEvent.save() = SaveEvent;

  const factory EditRawNoteEvent.shouldCheckChanges() = ShouldCheckChanges;

  @override
  List<Object?> get props => const [];
}

final class InitialEvent extends EditRawNoteEvent {
  const InitialEvent();
}

final class SaveEvent extends EditRawNoteEvent {
  const SaveEvent();
}

final class ShouldCheckChanges extends EditRawNoteEvent {
  const ShouldCheckChanges();
}
