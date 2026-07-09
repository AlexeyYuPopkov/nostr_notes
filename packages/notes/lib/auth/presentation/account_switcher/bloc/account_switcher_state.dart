import 'package:equatable/equatable.dart';

import 'account_switcher_data.dart';

sealed class AccountSwitcherState extends Equatable {
  final AccountSwitcherData data;

  const AccountSwitcherState({required this.data});

  @override
  List<Object?> get props => [data];

  const factory AccountSwitcherState.common({
    required AccountSwitcherData data,
  }) = CommonState;

  const factory AccountSwitcherState.loading({
    required AccountSwitcherData data,
  }) = LoadingState;

  const factory AccountSwitcherState.error({
    required AccountSwitcherData data,
    required Object e,
  }) = ErrorState;
}

final class CommonState extends AccountSwitcherState {
  const CommonState({required super.data});
}

final class LoadingState extends AccountSwitcherState {
  const LoadingState({required super.data});
}

final class ErrorState extends AccountSwitcherState {
  final Object e;
  const ErrorState({required super.data, required this.e});
}
