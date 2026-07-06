import 'package:equatable/equatable.dart';

sealed class AccountSwitcherEvent extends Equatable {
  const AccountSwitcherEvent();

  const factory AccountSwitcherEvent.initial() = InitialEvent;

  @override
  List<Object?> get props => const [];
}

final class InitialEvent extends AccountSwitcherEvent {
  const InitialEvent();
}