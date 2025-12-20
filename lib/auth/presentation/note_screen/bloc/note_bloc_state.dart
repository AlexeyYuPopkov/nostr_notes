import 'package:equatable/equatable.dart';
import 'package:nostr_notes/auth/presentation/note_screen/bloc/note_bloc_data.dart';

sealed class NoteBlocState extends Equatable {
  final NoteBlocData data;

  const NoteBlocState({required this.data});

  @override
  List<Object?> get props => [data];

  const factory NoteBlocState.common({required NoteBlocData data}) =
      CommonState;

  const factory NoteBlocState.loading({required NoteBlocData data}) =
      LoadingState;

  const factory NoteBlocState.error({
    required NoteBlocData data,
    required Object e,
  }) = ErrorState;

  const factory NoteBlocState.didSave({required NoteBlocData data}) =
      DidSaveState;
}

final class CommonState extends NoteBlocState {
  const CommonState({required super.data});
}

final class LoadingState extends NoteBlocState {
  const LoadingState({required super.data});
}

final class ErrorState extends NoteBlocState {
  final Object e;
  const ErrorState({required super.data, required this.e});
}

final class DidSaveState extends NoteBlocState {
  const DidSaveState({required super.data});
}
