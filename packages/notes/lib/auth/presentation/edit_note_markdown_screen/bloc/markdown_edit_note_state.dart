import 'package:equatable/equatable.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/auth/presentation/edit_note_markdown_screen/bloc/markdown_edit_note_data.dart';

sealed class MarkdownEditNoteState extends Equatable {
  final MarkdownEditNoteData data;

  const MarkdownEditNoteState({required this.data});

  @override
  List<Object?> get props => [data];

  const factory MarkdownEditNoteState.common({
    required MarkdownEditNoteData data,
  }) = CommonState;

  const factory MarkdownEditNoteState.loading({
    required MarkdownEditNoteData data,
  }) = LoadingState;

  const factory MarkdownEditNoteState.error({
    required MarkdownEditNoteData data,
    required Object e,
  }) = ErrorState;

  const factory MarkdownEditNoteState.didSave({
    required MarkdownEditNoteData data,
    required Note note,
  }) = DidSaveState;
}

final class CommonState extends MarkdownEditNoteState {
  const CommonState({required super.data});
}

final class LoadingState extends MarkdownEditNoteState {
  const LoadingState({required super.data});
}

final class ErrorState extends MarkdownEditNoteState {
  final Object e;
  const ErrorState({required super.data, required this.e});
}

final class DidSaveState extends MarkdownEditNoteState {
  final Note note;
  const DidSaveState({required super.data, required this.note});
}
