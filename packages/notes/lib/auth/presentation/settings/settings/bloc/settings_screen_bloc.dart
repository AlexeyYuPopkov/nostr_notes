import 'package:di_storage/di_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/common/domain/usecase/auth_usecase.dart';
import 'package:nostr_notes/common/domain/usecase/pin_usecase.dart';

import 'settings_screen_data.dart';
import 'settings_screen_event.dart';
import 'settings_screen_state.dart';

final class SettingsScreenBloc
    extends Bloc<SettingsScreenEvent, SettingsScreenState> {
  final AuthUsecase authUsecase = DiStorage.shared.resolve();
  final PinUsecase pinUsecase = DiStorage.shared.resolve();

  SettingsScreenData get data => state.data;

  SettingsScreenBloc()
    : super(SettingsScreenState.common(data: SettingsScreenData.initial())) {
    _setupHandlers();
  }

  void _setupHandlers() {
    on<ExitEvent>(_onExitEvent);
    on<LogoutEvent>(_onLogoutEvent);
  }

  void _onExitEvent(ExitEvent event, Emitter<SettingsScreenState> emit) async {
    try {
      emit(SettingsScreenState.loading(data: data));

      await authUsecase.restore();

      emit(SettingsScreenState.common(data: data));
    } catch (e) {
      emit(SettingsScreenState.error(e: e, data: data));
    }
  }

  void _onLogoutEvent(
    LogoutEvent event,
    Emitter<SettingsScreenState> emit,
  ) async {
    try {
      emit(SettingsScreenState.loading(data: data));

      await authUsecase.logout();

      emit(SettingsScreenState.common(data: data));
    } catch (e) {
      emit(SettingsScreenState.error(e: e, data: data));
    }
  }
}
