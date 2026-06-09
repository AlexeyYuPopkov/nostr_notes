import 'package:equatable/equatable.dart';
import 'package:nostr_notes/auth/domain/usecase/import_usecase.dart';

sealed class ExportImportEvent extends Equatable {
  const ExportImportEvent();

  const factory ExportImportEvent.export({required String password}) =
      ExportEvent;

  const factory ExportImportEvent.import({
    required String filePath,
    required String password,
    required ImportPolicy policy,
  }) = ImportEvent;

  @override
  List<Object?> get props => const [];
}

final class ExportEvent extends ExportImportEvent {
  final String password;

  const ExportEvent({required this.password});

  @override
  List<Object?> get props => [password];
}

final class ImportEvent extends ExportImportEvent {
  final String filePath;
  final String password;
  final ImportPolicy policy;

  const ImportEvent({
    required this.filePath,
    required this.password,
    required this.policy,
  });

  @override
  List<Object?> get props => [filePath, password, policy.runtimeType];
}
