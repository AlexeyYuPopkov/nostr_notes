import 'package:equatable/equatable.dart';

import 'settings_screen_data.dart';

sealed class SettingsScreenState extends Equatable {
  final SettingsScreenData data;

  const SettingsScreenState({required this.data});

  @override
  List<Object?> get props => [data];

  const factory SettingsScreenState.common({
    required SettingsScreenData data,
  }) = CommonState;

  const factory SettingsScreenState.loading({
    required SettingsScreenData data,
  }) = LoadingState;

  const factory SettingsScreenState.error({
    required SettingsScreenData data,
    required Object e,
  }) = ErrorState;
}

final class CommonState extends SettingsScreenState {
  const CommonState({required super.data});
}

final class LoadingState extends SettingsScreenState {
  const LoadingState({required super.data});
}

final class ErrorState extends SettingsScreenState {
  final Object e;
  const ErrorState({
    required super.data,
    required this.e,
  });
}
