import 'dart:typed_data';

import 'package:common/domain/error/app_error.dart';

abstract interface class ExportAccountsUsecase {
  /// Returns `(filePath, zipBytes, fileName)`.
  /// On web [filePath] is empty; callers must use [zipBytes] + [fileName]
  /// instead.
  ///
  /// Unlike [ExportUsecase] (notes), [password] is required and rejected if
  /// empty: an unencrypted backup would store account passwords as plain
  /// text in the zip, which — unlike an unencrypted note — is a directly
  /// usable credential.
  Future<(String, Uint8List, String)> exportAccounts({
    required String password,
    String? fileName,
  });
}

final class ExportAccountsError extends CustomError<ExportAccountsErrorType> {
  const ExportAccountsError({
    required super.payload,
    super.parentError,
    super.reason,
  });
}

enum ExportAccountsErrorType {
  /// There is nothing to export (empty vault or no decryptable accounts).
  noAccounts,

  /// [ExportAccountsUsecase.exportAccounts] was called with an empty
  /// password.
  passwordRequired,

  /// Password-based encryption of the backup failed.
  encryptionFailed,

  /// Writing/zipping the backup file failed.
  fileWriteFailed,

  /// Any other, unanticipated failure.
  unknown,
}
