import 'dart:typed_data';

import 'package:common/domain/error/app_error.dart';

/// On web [filePath] is empty; callers must use [bytes] + [fileName] instead.
typedef ExportAccountsResult = ({
  String filePath,
  Uint8List bytes,
  String fileName,

  /// Accounts left out of the backup because they could not be decrypted. A
  /// backup silently missing credentials is worse than one that says how
  /// many are gone.
  int skippedAccounts,
});

abstract interface class ExportAccountsUsecase {
  ///
  /// Unlike [ExportUsecase] (notes), [password] is required and rejected if
  /// empty: an unencrypted backup would store account passwords as plain
  /// text in the zip, which — unlike an unencrypted note — is a directly
  /// usable credential.
  ///
  /// [dTags], when provided, restricts the export to those items — used for
  /// a single account's "Share/Backup" action; omitted (or null) exports
  /// every account in the vault.
  Future<ExportAccountsResult> exportAccounts({
    required String password,
    String? fileName,
    List<String>? dTags,
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
