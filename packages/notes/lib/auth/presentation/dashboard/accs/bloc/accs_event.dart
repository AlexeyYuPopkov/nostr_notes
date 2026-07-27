import 'package:equatable/equatable.dart';

sealed class AccsEvent extends Equatable {
  const AccsEvent();

  const factory AccsEvent.initial() = InitialEvent;

  @override
  List<Object?> get props => const [];
}

final class InitialEvent extends AccsEvent {
  const InitialEvent();
}