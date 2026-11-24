import 'package:equatable/equatable.dart';

import 'relays_data.dart';

sealed class RelaysState extends Equatable {
  final RelaysData data;

  const RelaysState({required this.data});

  @override
  List<Object?> get props => [data];

  const factory RelaysState.common({required RelaysData data}) = RelaysCommon;

  const factory RelaysState.error({
    required RelaysData data,
    required Object error,
  }) = RelaysError;
}

final class RelaysCommon extends RelaysState {
  const RelaysCommon({required super.data});
}

final class RelaysError extends RelaysState {
  final Object error;
  const RelaysError({required super.data, required this.error});
}
