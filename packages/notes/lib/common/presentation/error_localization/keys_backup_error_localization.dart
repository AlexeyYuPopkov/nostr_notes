import 'package:nostr_notes/common/domain/usecase/keys_backup/export_keys_usecase.dart';
import 'package:nostr_notes/common/domain/usecase/keys_backup/keys_backup_error.dart';
import 'package:nostr_notes/l10n/localization.dart';

mixin KeysBackupErrorLocalization {
  String? keysBackupErrorMessage(Localization l10n, Object? error) {
    return switch (error) {
      KeysBackupError(:final payload) => switch (payload) {
        KeysBackupErrorType.passwordTooShort =>
          l10n.exportImportPasswordTooShort(
            ExportKeysUsecase.minPasswordLength.toString(),
          ),
        KeysBackupErrorType.invalidFile => l10n.keysBackupInvalidFileError,
        KeysBackupErrorType.unsupportedVersion =>
          l10n.keysBackupUnsupportedVersionError,
        KeysBackupErrorType.wrongPassword =>
          l10n.exportImportImportWrongPasswordError,
        KeysBackupErrorType.invalidKey => l10n.keysBackupInvalidKeyError,
        KeysBackupErrorType.fileWriteFailed => l10n.exportImportExportFileError,
        KeysBackupErrorType.noKeys || KeysBackupErrorType.unknown => null,
      },
      _ => null,
    };
  }
}
