import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_screen_data.dart';
import 'home_screen_event.dart';
import 'home_screen_state.dart';

final class HomeScreenBloc extends Bloc<HomeScreenEvent, HomeScreenState> {
  HomeScreenData get data => state.data;

  HomeScreenBloc()
      : super(
          HomeScreenState.common(
            data: HomeScreenData.initial(),
          ),
        ) {
    _setupHandlers();

    add(const HomeScreenEvent.initial());
  }

  void _setupHandlers() {
    on<InitialEvent>(_onInitialEvent);
  }

  void _onInitialEvent(
    InitialEvent event,
    Emitter<HomeScreenState> emit,
  ) async {
    try {
      emit(HomeScreenState.loading(data: data));

      await Future.delayed(const Duration(seconds: 2));

      emit(
        HomeScreenState.common(data: data),
      );
    } catch (e) {
      emit(HomeScreenState.error(e: e, data: data));
    }
  }
}
