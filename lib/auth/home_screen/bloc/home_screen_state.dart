import 'package:equatable/equatable.dart';
import 'package:nostr_notes/auth/home_screen/bloc/home_screen_data.dart';

sealed class HomeScreenState extends Equatable {
  final HomeScreenData data;

  const HomeScreenState({required this.data});

  @override
  List<Object?> get props => [data];

  const factory HomeScreenState.common({
    required HomeScreenData data,
  }) = CommonState;

  const factory HomeScreenState.loading({
    required HomeScreenData data,
  }) = LoadingState;

  const factory HomeScreenState.error({
    required HomeScreenData data,
    required Object e,
  }) = ErrorState;
}

final class CommonState extends HomeScreenState {
  const CommonState({required super.data});
}

final class LoadingState extends HomeScreenState {
  const LoadingState({required super.data});
}

final class ErrorState extends HomeScreenState {
  final Object e;
  const ErrorState({
    required super.data,
    required this.e,
  });
}
