import 'package:equatable/equatable.dart';
import 'edit_raw_note_data.dart';

sealed class EditRawNoteState extends Equatable {
  final EditRawNoteData data;

  const EditRawNoteState({required this.data});

  @override
  List<Object?> get props => [data];

  const factory EditRawNoteState.common({required EditRawNoteData data}) =
      CommonState;

  const factory EditRawNoteState.loading({required EditRawNoteData data}) =
      LoadingState;

  const factory EditRawNoteState.error({
    required EditRawNoteData data,
    required Object e,
  }) = ErrorState;

  const factory EditRawNoteState.didSave({required EditRawNoteData data}) =
      DidSaveState;
}

final class CommonState extends EditRawNoteState {
  const CommonState({required super.data});
}

final class LoadingState extends EditRawNoteState {
  const LoadingState({required super.data});
}

final class ErrorState extends EditRawNoteState {
  final Object e;
  const ErrorState({required super.data, required this.e});
}

final class DidSaveState extends EditRawNoteState {
  const DidSaveState({required super.data});
}
