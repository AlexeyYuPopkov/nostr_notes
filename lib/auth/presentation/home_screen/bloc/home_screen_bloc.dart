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
  }

  void _setupHandlers() {
    on<SelectNoteEvent>(_onSelectNoteEvent);
  }

  void _onSelectNoteEvent(
    SelectNoteEvent event,
    Emitter<HomeScreenState> emit,
  ) async {
    try {
      emit(
        HomeScreenState.didSelectNote(
          isMobile: event.isMobile,
          data: data.copyWith(
            selectedNoteDTag: event.selectedNoteDTag,
          ),
        ),
      );
    } catch (e) {
      emit(HomeScreenState.error(e: e, data: data));
    }
  }
}
