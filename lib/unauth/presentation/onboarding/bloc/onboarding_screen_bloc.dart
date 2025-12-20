import 'dart:async';
import 'package:di_storage/di_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/common/domain/usecase/auth_usecase.dart';
import 'package:nostr_notes/common/domain/usecase/pin_usecase.dart';
import 'package:nostr_notes/unauth/presentation/onboarding/pages/onboarding_step.dart';

import 'onboarding_screen_data.dart';
import 'onboarding_screen_event.dart';
import 'onboarding_screen_state.dart';

final class OnboardingScreenBloc
    extends Bloc<OnboardingScreenEvent, OnboardingScreenState> {
  OnboardingScreenData get data => state.data;

  final AuthUsecase authUsecase = DiStorage.shared.resolve();
  final PinUsecase pinUsecase = DiStorage.shared.resolve();
  late final StreamSubscription sessionSubscription;

  OnboardingScreenBloc()
    : super(
        OnboardingScreenState.common(data: OnboardingScreenData.initial()),
      ) {
    _setupHandlers();
    _setupSubscriptions();
    add(const OnboardingScreenEvent.initial());
  }

  void _setupSubscriptions() {
    sessionSubscription = authUsecase.session
        .distinct((a, b) => a.isAuth == b.isAuth)
        .listen((session) {
          if (session.isAuth) {
            add(const OnboardingScreenEvent.onStep(OnboardingPin()));
          }
        });
  }

  void _setupHandlers() {
    on<InitialEvent>(_onInitialEvent);
    on<OnStepEvent>(_onNextStepEvent);
    on<OnNsecEvent>(_onOnNsecEvent);
    on<OnPinEvent>(_onOnPinEvent);
  }

  @override
  Future<void> close() {
    sessionSubscription.cancel();
    return super.close();
  }

  void _onInitialEvent(
    InitialEvent event,
    Emitter<OnboardingScreenState> emit,
  ) async {
    try {
      emit(OnboardingScreenState.loading(data: data));

      await Future.delayed(const Duration(seconds: 2));

      emit(OnboardingScreenState.common(data: data));
    } catch (e) {
      emit(OnboardingScreenState.error(e: e, data: data));
    }
  }

  void _onNextStepEvent(
    OnStepEvent event,
    Emitter<OnboardingScreenState> emit,
  ) {
    emit(OnboardingScreenState.common(data: data.copyWith(step: event.step)));
  }

  void _onOnNsecEvent(
    OnNsecEvent event,
    Emitter<OnboardingScreenState> emit,
  ) async {
    try {
      emit(OnboardingScreenState.loading(data: data));
      event.vm.setLoading();

      await authUsecase.execute(nsec: event.nsec);

      emit(OnboardingScreenState.common(data: data));
    } catch (e) {
      event.vm.setCompleted();
      emit(OnboardingScreenState.error(e: e, data: data));
    }
  }

  void _onOnPinEvent(
    OnPinEvent event,
    Emitter<OnboardingScreenState> emit,
  ) async {
    try {
      emit(OnboardingScreenState.loading(data: data));
      event.vm.setLoading();

      await pinUsecase.execute(pin: event.pin, usePin: event.usePin);

      emit(OnboardingScreenState.didUnlock(data: data));
    } catch (e) {
      event.vm.setCompleted();
      emit(OnboardingScreenState.error(e: e, data: data));
    }
  }
}
