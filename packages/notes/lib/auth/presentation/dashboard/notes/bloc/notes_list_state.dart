import 'package:equatable/equatable.dart';

import 'notes_list_data.dart';

sealed class NotesListState extends Equatable {
  final NotesListData data;

  const NotesListState({required this.data});

  @override
  List<Object?> get props => [data];

  const factory NotesListState.common({required NotesListData data}) =
      CommonState;

  const factory NotesListState.loading({required NotesListData data}) =
      LoadingState;

  const factory NotesListState.error({
    required NotesListData data,
    required Object e,
  }) = ErrorState;
}

final class CommonState extends NotesListState {
  const CommonState({required super.data});
}

final class LoadingState extends NotesListState {
  const LoadingState({required super.data});
}

final class ErrorState extends NotesListState {
  final Object e;
  const ErrorState({required super.data, required this.e});
}
