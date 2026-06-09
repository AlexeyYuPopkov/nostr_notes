import 'package:common/domain/error/app_error.dart';

abstract interface class ExportUsecase {
  Future<String> exportNotes({
    required String password,
    required String fileUri,
  });
}

final class ExportError extends CustomError<ExportErrorType> {
  const ExportError({required super.payload, super.parentError, super.reason});
}

enum ExportErrorType {
  /// There is nothing to export (empty store or no decryptable notes).
  noNotes,

  /// Password-based encryption of the backup failed.
  encryptionFailed,

  /// Writing/zipping the backup file failed.
  fileWriteFailed,

  /// Any other, unanticipated failure.
  unknown,
}
