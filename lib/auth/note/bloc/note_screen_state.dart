import 'package:equatable/equatable.dart';

import 'note_screen_data.dart';

sealed class NoteScreenState extends Equatable {
  final NoteScreenData data;

  const NoteScreenState({required this.data});

  @override
  List<Object?> get props => [data];

  const factory NoteScreenState.common({
    required NoteScreenData data,
  }) = CommonState;

  const factory NoteScreenState.loading({
    required NoteScreenData data,
  }) = LoadingState;

  const factory NoteScreenState.error({
    required NoteScreenData data,
    required Object e,
  }) = ErrorState;
}

final class CommonState extends NoteScreenState {
  const CommonState({required super.data});
}

final class LoadingState extends NoteScreenState {
  const LoadingState({required super.data});
}

final class ErrorState extends NoteScreenState {
  final Object e;
  const ErrorState({
    required super.data,
    required this.e,
  });
}
