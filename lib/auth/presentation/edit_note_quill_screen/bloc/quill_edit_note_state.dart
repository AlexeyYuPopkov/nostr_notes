import 'package:equatable/equatable.dart';
import 'package:nostr_notes/auth/presentation/edit_note_quill_screen/bloc/quill_edit_note_data.dart';

sealed class QuillEditNoteState extends Equatable {
  final QuillEditNoteData data;

  const QuillEditNoteState({required this.data});

  @override
  List<Object?> get props => [data];

  const factory QuillEditNoteState.common({required QuillEditNoteData data}) =
      CommonState;

  const factory QuillEditNoteState.loading({required QuillEditNoteData data}) =
      LoadingState;

  const factory QuillEditNoteState.error({
    required QuillEditNoteData data,
    required Object e,
  }) = ErrorState;

  const factory QuillEditNoteState.didSave({required QuillEditNoteData data}) =
      DidSaveState;
}

final class CommonState extends QuillEditNoteState {
  const CommonState({required super.data});
}

final class LoadingState extends QuillEditNoteState {
  const LoadingState({required super.data});
}

final class ErrorState extends QuillEditNoteState {
  final Object e;
  const ErrorState({required super.data, required this.e});
}

final class DidSaveState extends QuillEditNoteState {
  const DidSaveState({required super.data});
}
