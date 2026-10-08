import 'package:common/domain/error/app_error.dart';

final class KeysBackupError extends CustomError<KeysBackupErrorType> {
  const KeysBackupError({
    required super.payload,
    super.parentError,
    super.reason,
  });
}

enum KeysBackupErrorType {
  /// Shorter than `ExportKeysUsecase.minPasswordLength`.
  passwordTooShort,

  noKeys,

  /// Not a zip, or a zip without a keys payload (e.g. a notes backup).
  invalidFile,

  unsupportedVersion,

  /// Decryption failed — wrong password or the backup is corrupted.
  wrongPassword,

  /// The backup decrypted, but holds something that is not a valid nsec.
  invalidKey,

  fileWriteFailed,

  unknown,
}
