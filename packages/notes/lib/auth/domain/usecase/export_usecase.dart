import 'dart:typed_data';

import 'package:common/domain/error/app_error.dart';

sealed class ExportParams {
  String get password;
  String get fileUri;

  const ExportParams();
}

final class ExportParamsAll extends ExportParams {
  @override
  final String password;
  @override
  final String fileUri;

  const ExportParamsAll({required this.password, required this.fileUri});
}

final class ExportParamsIds extends ExportParams {
  final List<String> noteIds;
  @override
  final String password;
  @override
  final String fileUri;

  const ExportParamsIds({
    required this.noteIds,
    required this.password,
    required this.fileUri,
  });
}

abstract interface class ExportUsecase {
  /// Returns `(filePath, zipBytes, fileName)`.
  /// On web [filePath] is empty; callers must use [zipBytes] + [fileName] instead.
  Future<(String, Uint8List, String)> exportNotes({
    required ExportParams params,
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
