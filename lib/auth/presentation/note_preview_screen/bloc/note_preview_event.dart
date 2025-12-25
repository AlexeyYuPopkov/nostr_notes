import 'package:equatable/equatable.dart';

sealed class NotePreviewEvent extends Equatable {
  const NotePreviewEvent();

  const factory NotePreviewEvent.initial() = InitialEvent;

  @override
  List<Object?> get props => const [];
}

final class InitialEvent extends NotePreviewEvent {
  const InitialEvent();
}
