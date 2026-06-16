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
  }) = SuccessState;

  const factory ExportImportState.error({
    required ExportImportData data,
    required Object error,
  }) = ErrorState;

  const factory ExportImportState.willImport({required ExportImportData data}) =
      WillImport;

  const factory ExportImportState.importSuccess({
    required ExportImportData data,
  }) = ImportSuccessState;
}

final class WillImport extends ExportImportState {
  const WillImport({required super.data});
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

  const SuccessState({
    required super.data,
    required this.filePath,
    required this.bytes,
    required this.fileName,
  });

  @override
  List<Object?> get props => [data, filePath, fileName];
}

final class ImportSuccessState extends ExportImportState {
  const ImportSuccessState({required super.data});
}

final class ErrorState extends ExportImportState {
  final Object error;

  const ErrorState({required super.data, required this.error});

  @override
  List<Object?> get props => [data, error];
}
