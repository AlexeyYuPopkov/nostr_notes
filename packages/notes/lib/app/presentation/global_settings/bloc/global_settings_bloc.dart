import 'package:di_storage/di_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/app/domain/theme_mode_repo.dart';
import 'package:rxdart/rxdart.dart';

import 'global_settings_data.dart';
import 'global_settings_event.dart';
import 'global_settings_state.dart';

final class GlobalSettingsBloc
    extends Bloc<GlobalSettingsEvent, GlobalSettingsState> {
  GlobalSettingsData get data => state.data;
  late final ThemeModeRepo _themeModeRepo = DiStorage.shared.resolve();

  GlobalSettingsBloc()
    : super(
        GlobalSettingsState.common(
          data: GlobalSettingsData.initial(
            DiStorage.shared.resolve<ThemeModeRepo>().get().toThemeMode(),
          ),
        ),
      ) {
    _setupHandlers();

    add(const GlobalSettingsEvent.initial());
  }

  void _setupHandlers() {
    on<InitialEvent>(_onInitialEvent);
    on<ThemeChangedEvent>(
      _onThemeChangedEvent,
      transformer: (events, mapper) =>
          events.debounceTime(Durations.short4).switchMap(mapper),
    );
  }

  void _onInitialEvent(
    InitialEvent event,
    Emitter<GlobalSettingsState> emit,
  ) async {
    try {
      final themeMode = _themeModeRepo.get().toThemeMode();

      if (data.themeMode == themeMode) {
        return;
      }

      emit(
        GlobalSettingsState.common(data: data.copyWith(themeMode: themeMode)),
      );
    } catch (e) {
      emit(GlobalSettingsState.error(e: e, data: data));
    }
  }

  void _onThemeChangedEvent(
    ThemeChangedEvent event,
    Emitter<GlobalSettingsState> emit,
  ) async {
    try {
      if (data.themeMode == event.mode) {
        return;
      }
      emit(GlobalSettingsState.loading(data: data));
      await _themeModeRepo.set(event.mode.toAppThemeMode());
      add(const GlobalSettingsEvent.initial());
    } catch (e) {
      emit(GlobalSettingsState.error(e: e, data: data));
    }
  }
}

extension on AppThemeMode {
  ThemeMode toThemeMode() {
    switch (this) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }
}

extension on ThemeMode {
  AppThemeMode toAppThemeMode() {
    switch (this) {
      case ThemeMode.system:
        return AppThemeMode.system;
      case ThemeMode.light:
        return AppThemeMode.light;
      case ThemeMode.dark:
        return AppThemeMode.dark;
    }
  }
}
