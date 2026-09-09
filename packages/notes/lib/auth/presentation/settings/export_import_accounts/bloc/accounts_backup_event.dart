import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:nostr_notes/auth/domain/usecase/login_items/import_accounts_usecase.dart';

sealed class AccountsBackupEvent extends Equatable {
  const AccountsBackupEvent();

  const factory AccountsBackupEvent.export({
    required String password,
    String? fileName,
  }) = ExportAccountsEvent;

  const factory AccountsBackupEvent.willImport() = WillImportAccountsEvent;
  const factory AccountsBackupEvent.willExport() = WillExportAccountsEvent;

  const factory AccountsBackupEvent.import({
    required PlatformFile? file,
    required String password,
    required LoginItemImportPolicy policy,
  }) = ImportAccountsEvent;

  @override
  List<Object?> get props => const [];
}

final class WillExportAccountsEvent extends AccountsBackupEvent {
  const WillExportAccountsEvent();
}

final class ExportAccountsEvent extends AccountsBackupEvent {
  final String password;
  final String? fileName;

  const ExportAccountsEvent({required this.password, this.fileName});

  @override
  List<Object?> get props => [password, fileName];
}

final class WillImportAccountsEvent extends AccountsBackupEvent {
  const WillImportAccountsEvent();
}

final class ImportAccountsEvent extends AccountsBackupEvent {
  final PlatformFile? file;
  final String password;
  final LoginItemImportPolicy policy;

  const ImportAccountsEvent({
    required this.file,
    required this.password,
    required this.policy,
  });

  @override
  List<Object?> get props => [file, password, policy.runtimeType];
}
