import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:nostr_notes/auth/domain/usecase/import_usecase.dart';

sealed class ExportImportEvent extends Equatable {
  const ExportImportEvent();

  const factory ExportImportEvent.export({
    required String password,
    String? fileName,
  }) = ExportEvent;

  const factory ExportImportEvent.willImport() = WillImportEvent;
  const factory ExportImportEvent.willExport() = WillExportEvent;

  const factory ExportImportEvent.import({
    required PlatformFile? file,
    required String password,
    required ImportPolicy policy,
  }) = ImportEvent;

  @override
  List<Object?> get props => const [];
}

final class WillExportEvent extends ExportImportEvent {
  const WillExportEvent();
}

final class ExportEvent extends ExportImportEvent {
  final String password;
  final String? fileName;

  const ExportEvent({required this.password, this.fileName});

  @override
  List<Object?> get props => [password, fileName];
}

final class WillImportEvent extends ExportImportEvent {
  const WillImportEvent();
}

final class ImportEvent extends ExportImportEvent {
  final PlatformFile? file;

  final String password;
  final ImportPolicy policy;

  const ImportEvent({
    required this.file,
    required this.password,
    required this.policy,
  });

  @override
  List<Object?> get props => [file, password, policy.runtimeType];
}
