import 'package:equatable/equatable.dart';

sealed class NoteBlocEvent extends Equatable {
  const NoteBlocEvent();

  const factory NoteBlocEvent.initial() = InitialEvent;

  const factory NoteBlocEvent.save() = SaveEvent;

  const factory NoteBlocEvent.shouldCheckChanges() = ShouldCheckChanges;

  @override
  List<Object?> get props => const [];
}

final class InitialEvent extends NoteBlocEvent {
  const InitialEvent();
}

final class SaveEvent extends NoteBlocEvent {
  const SaveEvent();
}

final class ShouldCheckChanges extends NoteBlocEvent {
  const ShouldCheckChanges();
}
