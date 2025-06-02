import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'onboarding_screen_data.dart';
import 'onboarding_screen_event.dart';
import 'onboarding_screen_state.dart';

final class OnboardingScreenBloc
    extends Bloc<OnboardingScreenEvent, OnboardingScreenState> {
  OnboardingScreenData get data => state.data;

  OnboardingScreenBloc()
      : super(
          OnboardingScreenState.common(
            data: OnboardingScreenData.initial(),
          ),
        ) {
    _setupHandlers();

    add(const OnboardingScreenEvent.initial());
  }

  void _setupHandlers() {
    on<InitialEvent>(_onInitialEvent);

    on<NextStepEvent>(_onNextStepEvent);
  }

  void _onInitialEvent(
    InitialEvent event,
    Emitter<OnboardingScreenState> emit,
  ) async {
    try {
      emit(OnboardingScreenState.loading(data: data));

      await Future.delayed(const Duration(seconds: 2));

      // throw CommonError(message: '');

      emit(
        OnboardingScreenState.common(data: data),
      );
    } catch (e) {
      emit(OnboardingScreenState.error(e: e, data: data));
    }
  }

  void _onNextStepEvent(
    NextStepEvent event,
    Emitter<OnboardingScreenState> emit,
  ) {
    emit(
      OnboardingScreenState.common(
        data: data.copyWith(
          step: data.step.getNextStep() ?? data.step,
        ),
      ),
    );
  }
}
