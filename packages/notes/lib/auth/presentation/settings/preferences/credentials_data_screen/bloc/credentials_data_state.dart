import 'package:equatable/equatable.dart';
import 'package:nostr_notes/auth/presentation/settings/preferences/credentials_data_screen/bloc/credentials_data_data.dart';

sealed class CredentialsDataState extends Equatable {
  final CredentialsDataData data;

  const CredentialsDataState({required this.data});

  @override
  List<Object?> get props => [data];

  const factory CredentialsDataState.common({
    required CredentialsDataData data,
  }) = CommonState;

  const factory CredentialsDataState.loading({
    required CredentialsDataData data,
  }) = LoadingState;

  const factory CredentialsDataState.error({
    required CredentialsDataData data,
    required Object error,
  }) = ErrorState;
}

final class CommonState extends CredentialsDataState {
  const CommonState({required super.data});
}

final class LoadingState extends CredentialsDataState {
  const LoadingState({required super.data});
}

final class ErrorState extends CredentialsDataState {
  final Object error;
  const ErrorState({required super.data, required this.error});
}
