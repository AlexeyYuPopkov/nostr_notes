import 'package:equatable/equatable.dart';

import 'del_acc_data.dart';

sealed class DelAccState extends Equatable {
  final DelAccData data;

  const DelAccState({required this.data});

  @override
  List<Object?> get props => [data];

  const factory DelAccState.common({required DelAccData data}) = CommonState;

  const factory DelAccState.executing({required DelAccData data}) =
      ExecutingState;

  const factory DelAccState.error({
    required DelAccData data,
    required Object e,
  }) = ErrorState;
}

final class CommonState extends DelAccState {
  const CommonState({required super.data});
}

final class ExecutingState extends DelAccState {
  const ExecutingState({required super.data});
}

final class ErrorState extends DelAccState {
  final Object e;
  const ErrorState({required super.data, required this.e});
}
