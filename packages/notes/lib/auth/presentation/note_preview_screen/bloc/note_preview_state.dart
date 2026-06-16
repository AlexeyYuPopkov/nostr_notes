import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:nostr_notes/auth/presentation/note_preview_screen/bloc/note_preview_data.dart';

sealed class NotePreviewState extends Equatable {
  final NotePreviewData data;

  const NotePreviewState({required this.data});

  @override
  List<Object?> get props => [data];

  const factory NotePreviewState.common({required NotePreviewData data}) =
      CommonState;

  const factory NotePreviewState.loading({
    required NotePreviewData data,
    double? progress,
  }) = LoadingState;

  const factory NotePreviewState.cannotDecrypt({
    required NotePreviewData data,
  }) = CannotDecryptState;

  const factory NotePreviewState.error({
    required NotePreviewData data,
    required Object error,
  }) = ErrorState;

  const factory NotePreviewState.willExportNote({
    required NotePreviewData data,
  }) = WillExportNoteState;

  const factory NotePreviewState.exportSuccess({
    required NotePreviewData data,
    required String filePath,
    required Uint8List bytes,
    required String fileName,
  }) = ExportNoteSuccessState;
}

final class CommonState extends NotePreviewState {
  const CommonState({required super.data});
}

final class LoadingState extends NotePreviewState {
  final double? progress;
  const LoadingState({required super.data, this.progress});

  @override
  List<Object?> get props => [data, progress];
}

final class CannotDecryptState extends NotePreviewState {
  const CannotDecryptState({required super.data});
}

final class ErrorState extends NotePreviewState {
  final Object error;
  const ErrorState({required super.data, required this.error});
}

final class WillExportNoteState extends NotePreviewState {
  const WillExportNoteState({required super.data});

  @override
  bool operator ==(Object other) => identical(this, other);

  @override
  int get hashCode => identityHashCode(this);
}

final class ExportNoteSuccessState extends NotePreviewState {
  final String filePath;
  final Uint8List bytes;
  final String fileName;

  const ExportNoteSuccessState({
    required super.data,
    required this.filePath,
    required this.bytes,
    required this.fileName,
  });

  @override
  bool operator ==(Object other) => identical(this, other);

  @override
  int get hashCode => identityHashCode(this);
}
