import 'package:equatable/equatable.dart';

import 'dashboard_data.dart';

sealed class DashboardState extends Equatable {
  final DashboardData data;

  const DashboardState({required this.data});

  @override
  List<Object?> get props => [data];

  const factory DashboardState.common({required DashboardData data}) =
      CommonState;

  const factory DashboardState.error({
    required DashboardData data,
    required Object e,
  }) = ErrorState;
}

final class CommonState extends DashboardState {
  const CommonState({required super.data});
}

final class ErrorState extends DashboardState {
  final Object e;
  const ErrorState({required super.data, required this.e});
}
