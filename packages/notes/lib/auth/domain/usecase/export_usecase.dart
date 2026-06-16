import 'dart:typed_data';

import 'package:common/domain/error/app_error.dart';

sealed class ExportParams {
  String get password;

  /// Optional user-provided base file name (without extension). When null or
  /// blank, a timestamped default is used.
  String? get fileName;

  const ExportParams();
}

final class ExportParamsAll extends ExportParams {
  @override
  final String password;
  @override
  final String? fileName;

  const ExportParamsAll({required this.password, this.fileName});
}

final class ExportParamsIds extends ExportParams {
  final List<String> noteIds;
  @override
  final String password;
  @override
  final String? fileName;

  const ExportParamsIds({
    required this.noteIds,
    required this.password,
    this.fileName,
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
