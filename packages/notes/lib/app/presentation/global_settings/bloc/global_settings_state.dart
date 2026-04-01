import 'package:equatable/equatable.dart';

import 'global_settings_data.dart';

sealed class GlobalSettingsState extends Equatable {
  final GlobalSettingsData data;

  const GlobalSettingsState({required this.data});

  @override
  List<Object?> get props => [data];

  const factory GlobalSettingsState.common({required GlobalSettingsData data}) =
      CommonState;

  const factory GlobalSettingsState.loading({
    required GlobalSettingsData data,
  }) = LoadingState;

  const factory GlobalSettingsState.error({
    required GlobalSettingsData data,
    required Object e,
  }) = ErrorState;
}

final class CommonState extends GlobalSettingsState {
  const CommonState({required super.data});
}

final class LoadingState extends GlobalSettingsState {
  const LoadingState({required super.data});
}

final class ErrorState extends GlobalSettingsState {
  final Object e;
  const ErrorState({required super.data, required this.e});
}
