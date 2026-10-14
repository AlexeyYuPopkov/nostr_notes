import 'package:equatable/equatable.dart';
import 'package:nostr_notes/common/domain/usecase/keys_backup/export_keys_usecase.dart';

import 'onboarding_screen_data.dart';

sealed class OnboardingScreenState extends Equatable {
  final OnboardingScreenData data;

  const OnboardingScreenState({required this.data});

  @override
  List<Object?> get props => [data];

  const factory OnboardingScreenState.initial({
    required OnboardingScreenData data,
  }) = InitialState;

  const factory OnboardingScreenState.common({
    required OnboardingScreenData data,
  }) = CommonState;

  const factory OnboardingScreenState.loading({
    required OnboardingScreenData data,
  }) = LoadingState;

  const factory OnboardingScreenState.error({
    required OnboardingScreenData data,
    required Object e,
  }) = ErrorState;

  const factory OnboardingScreenState.didUnlock({
    required OnboardingScreenData data,
  }) = DidUnlockState;

  const factory OnboardingScreenState.keyBackupReady({
    required OnboardingScreenData data,
    required KeysBackupFile file,
  }) = KeyBackupReadyState;
}

/// The encrypted key file is built and waits to be shared or saved.
final class KeyBackupReadyState extends OnboardingScreenState {
  final KeysBackupFile file;
  const KeyBackupReadyState({required super.data, required this.file});

  @override
  List<Object?> get props => [data, file.fileName, file.bytes];
}

final class InitialState extends OnboardingScreenState {
  const InitialState({required super.data});
}

final class CommonState extends OnboardingScreenState {
  const CommonState({required super.data});
}

final class LoadingState extends OnboardingScreenState {
  const LoadingState({required super.data});
}

final class DidUnlockState extends OnboardingScreenState {
  const DidUnlockState({required super.data});
}

final class ErrorState extends OnboardingScreenState {
  final Object e;
  const ErrorState({required super.data, required this.e});
}
