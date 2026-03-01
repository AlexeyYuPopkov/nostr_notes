import 'package:equatable/equatable.dart';

import 'app_settings_data.dart';

sealed class AppSettingsState extends Equatable {
  final AppSettingsData data;

  const AppSettingsState({required this.data});

  @override
  List<Object?> get props => [data];

  const factory AppSettingsState.common({required AppSettingsData data}) =
      CommonState;

  const factory AppSettingsState.loading({required AppSettingsData data}) =
      LoadingState;

  const factory AppSettingsState.error({
    required AppSettingsData data,
    required Object e,
  }) = ErrorState;
}

final class CommonState extends AppSettingsState {
  const CommonState({required super.data});
}

final class LoadingState extends AppSettingsState {
  const LoadingState({required super.data});
}

final class ErrorState extends AppSettingsState {
  final Object e;
  const ErrorState({required super.data, required this.e});
}
