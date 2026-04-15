import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_settings_data.dart';
import 'app_settings_event.dart';
import 'app_settings_state.dart';

final class AppSettingsBloc extends Bloc<AppSettingsEvent, AppSettingsState> {
  AppSettingsData get data => state.data;

  AppSettingsBloc()
    : super(AppSettingsState.common(data: AppSettingsData.initial())) {
    _setupHandlers();

    add(const AppSettingsEvent.initial());
  }

  void _setupHandlers() {
    on<InitialEvent>(_onInitialEvent);
  }

  void _onInitialEvent(
    InitialEvent event,
    Emitter<AppSettingsState> emit,
  ) async {
    try {
      emit(AppSettingsState.loading(data: data));

      await Future.delayed(const Duration(seconds: 2));

      emit(AppSettingsState.common(data: data));
    } catch (e) {
      emit(AppSettingsState.error(e: e, data: data));
    }
  }
}
