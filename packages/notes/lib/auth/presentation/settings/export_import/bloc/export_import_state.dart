import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:nostr_notes/auth/presentation/settings/export_import/bloc/export_import_data.dart';

sealed class ExportImportState extends Equatable {
  final ExportImportData data;

  const ExportImportState({required this.data});

  @override
  List<Object?> get props => [data];

  const factory ExportImportState.idle({required ExportImportData data}) =
      IdleState;

  const factory ExportImportState.loading({
    required ExportImportData data,
    double? progress,
  }) = LoadingState;

  const factory ExportImportState.success({
    required ExportImportData data,
    required String filePath,
    required Uint8List bytes,
    required String fileName,
    required int skippedNotes,
  }) = SuccessState;

  const factory ExportImportState.error({
    required ExportImportData data,
    required Object error,
  }) = ErrorState;

  const factory ExportImportState.willImport({required ExportImportData data}) =
      WillImport;

  const factory ExportImportState.willExport({required ExportImportData data}) =
      WillExport;

  const factory ExportImportState.importSuccess({
    required ExportImportData data,
    required int skippedNotes,
  }) = ImportSuccessState;
}

final class WillExport extends ExportImportState {
  const WillExport({required super.data});

  @override
  bool operator ==(Object other) => identical(this, other);

  @override
  int get hashCode => identityHashCode(this);
}

final class WillImport extends ExportImportState {
  const WillImport({required super.data});

  @override
  bool operator ==(Object other) => identical(this, other);

  @override
  int get hashCode => identityHashCode(this);
}

final class IdleState extends ExportImportState {
  const IdleState({required super.data});
}

final class LoadingState extends ExportImportState {
  final double? progress;
  const LoadingState({required super.data, this.progress});

  @override
  List<Object?> get props => [data, progress];
}

final class SuccessState extends ExportImportState {
  final String filePath;
  final Uint8List bytes;
  final String fileName;

  /// Notes left out of the backup because they could not be decrypted.
  final int skippedNotes;

  const SuccessState({
    required super.data,
    required this.filePath,
    required this.bytes,
    required this.fileName,
    required this.skippedNotes,
  });

  @override
  bool operator ==(Object other) => identical(this, other);

  @override
  int get hashCode => identityHashCode(this);
}

final class ImportSuccessState extends ExportImportState {
  /// Notes left un-imported because the stored note they collide with could
  /// not be decrypted, and overwriting something unreadable would lose it.
  final int skippedNotes;

  const ImportSuccessState({required super.data, required this.skippedNotes});

  @override
  bool operator ==(Object other) => identical(this, other);

  @override
  int get hashCode => identityHashCode(this);
}

final class ErrorState extends ExportImportState {
  final Object error;

  const ErrorState({required super.data, required this.error});

  @override
  List<Object?> get props => [data, error];
}
