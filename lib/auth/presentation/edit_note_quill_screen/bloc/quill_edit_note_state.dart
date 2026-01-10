import 'package:equatable/equatable.dart';
import 'package:nostr_notes/auth/presentation/note_screen/bloc/note_bloc_data.dart';

sealed class QuillEditNoteState extends Equatable {
  final NoteBlocData data;

  const QuillEditNoteState({required this.data});

  @override
  List<Object?> get props => [data];

  const factory QuillEditNoteState.common({required NoteBlocData data}) =
      CommonState;

  const factory QuillEditNoteState.loading({required NoteBlocData data}) =
      LoadingState;

  const factory QuillEditNoteState.error({
    required NoteBlocData data,
    required Object e,
  }) = ErrorState;

  const factory QuillEditNoteState.didSave({required NoteBlocData data}) =
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
