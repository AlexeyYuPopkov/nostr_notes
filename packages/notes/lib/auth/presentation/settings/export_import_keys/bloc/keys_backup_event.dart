import 'package:equatable/equatable.dart';

sealed class KeysBackupEvent extends Equatable {
  const KeysBackupEvent();

  /// Exports the current account's key.
  const factory KeysBackupEvent.export({
    required String password,
    String? fileName,
  }) = ExportKeyEvent;

  @override
  List<Object?> get props => const [];
}

final class ExportKeyEvent extends KeysBackupEvent {
  final String password;
  final String? fileName;

  const ExportKeyEvent({required this.password, this.fileName});
}
