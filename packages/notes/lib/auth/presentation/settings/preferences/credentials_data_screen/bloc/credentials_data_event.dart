import 'package:equatable/equatable.dart';

sealed class CredentialsDataEvent extends Equatable {
  const CredentialsDataEvent();

  const factory CredentialsDataEvent.initial() = InitialEvent;

  const factory CredentialsDataEvent.saveKeyBackup({
    required String password,
    String? fileName,
  }) = SaveKeyBackupEvent;

  @override
  List<Object?> get props => const [];
}

final class InitialEvent extends CredentialsDataEvent {
  const InitialEvent();
}

final class SaveKeyBackupEvent extends CredentialsDataEvent {
  final String password;
  final String? fileName;
  const SaveKeyBackupEvent({required this.password, this.fileName});
}
