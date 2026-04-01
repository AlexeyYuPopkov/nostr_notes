import 'package:equatable/equatable.dart';

sealed class CredentialsDataEvent extends Equatable {
  const CredentialsDataEvent();

  const factory CredentialsDataEvent.initial() = InitialEvent;

  @override
  List<Object?> get props => const [];
}

final class InitialEvent extends CredentialsDataEvent {
  const InitialEvent();
}
