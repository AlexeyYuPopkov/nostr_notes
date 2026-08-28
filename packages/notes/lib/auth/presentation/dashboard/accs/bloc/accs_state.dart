import 'package:equatable/equatable.dart';

import 'accs_data.dart';

sealed class AccsState extends Equatable {
  final AccsData data;

  const AccsState({required this.data});

  @override
  List<Object?> get props => [data];

  const factory AccsState.common({required AccsData data}) = CommonState;

  const factory AccsState.loading({required AccsData data}) = LoadingState;

  const factory AccsState.error({required AccsData data, required Object e}) =
      ErrorState;
}

final class CommonState extends AccsState {
  const CommonState({required super.data});
}

final class LoadingState extends AccsState {
  const LoadingState({required super.data});
}

final class ErrorState extends AccsState {
  final Object e;
  const ErrorState({required super.data, required this.e});
}
