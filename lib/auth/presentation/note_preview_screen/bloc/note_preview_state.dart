import 'package:equatable/equatable.dart';
import 'package:nostr_notes/auth/presentation/note_preview_screen/bloc/note_preview_data.dart';

sealed class NotePreviewState extends Equatable {
  final NotePreviewData data;

  const NotePreviewState({required this.data});

  @override
  List<Object?> get props => [data];

  const factory NotePreviewState.common({required NotePreviewData data}) =
      CommonState;

  const factory NotePreviewState.loading({required NotePreviewData data}) =
      LoadingState;

  const factory NotePreviewState.error({
    required NotePreviewData data,
    required Object e,
  }) = ErrorState;
}

final class CommonState extends NotePreviewState {
  const CommonState({required super.data});
}

final class LoadingState extends NotePreviewState {
  const LoadingState({required super.data});
}

final class ErrorState extends NotePreviewState {
  final Object e;
  const ErrorState({required super.data, required this.e});
}
