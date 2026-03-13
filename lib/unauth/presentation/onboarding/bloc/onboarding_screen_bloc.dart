import 'dart:async';
import 'package:di_storage/di_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/auth/domain/repo/pin_enabled_repo.dart';
import 'package:nostr_notes/auth/domain/repo/pin_keyboard_type_repo.dart';
import 'package:nostr_notes/auth/domain/repo/relays_list_repo.dart';
import 'package:nostr_notes/common/domain/usecase/auth_usecase.dart';
import 'package:nostr_notes/common/domain/usecase/pin_usecase.dart';
import 'package:nostr_notes/unauth/presentation/onboarding/pages/onboarding_nsec_page/onboarding_nsec_page.dart';
import 'package:nostr_notes/unauth/presentation/onboarding/pages/onboarding_step.dart';

import 'onboarding_screen_data.dart';
import 'onboarding_screen_event.dart';
import 'onboarding_screen_state.dart';

final class OnboardingScreenBloc
    extends Bloc<OnboardingScreenEvent, OnboardingScreenState> {
  OnboardingScreenData get data => state.data;
  DiStorage get _di => DiStorage.shared;

  late final AuthUsecase authUsecase = _di.resolve();
  late final PinUsecase pinUsecase = _di.resolve();
  late final RelaysListRepo relaysListRepo = _di.resolve();
  late final StreamSubscription sessionSubscription;
  StreamSubscription? relaysSubscription;
  late final nsecPageVm = OnboardingNsecPageVm();
  late final PinKeyboardTypeRepo _pinKeyboardTypeRepo = _di.resolve();
  late final PinEnabledRepo _pinEnabledRepo = _di.resolve();

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
            final hasRelays = relaysListRepo.getRelaysList().isNotEmpty;
            final step = hasRelays
                ? const OnboardingPin()
                : const OnboardingRelays();
            add(OnboardingScreenEvent.onStep(step));
          }
          final publicKey = session.keys?.publicKey;

          if (publicKey != null && publicKey.isNotEmpty) {
            final isUsePin = _pinEnabledRepo.getForUser(publicKey);
            add(OnboardingScreenEvent.usePinFlagUpdated(isUsePin));
          }
        });
  }

  void _setupHandlers() {
    on<InitialEvent>(_onInitialEvent);
    on<OnStepEvent>(_onNextStepEvent);
    on<OnNsecEvent>(_onOnNsecEvent);
    on<OnPinEvent>(_onOnPinEvent);
    on<OnGenerateKeyEvent>(_onGenerateKeyEvent);
    on<OnNsecGeneratedEvent>(_onNsecGeneratedEvent);
    on<OnRelaysSelectedEvent>(_onRelaysSelectedEvent);
    on<UsePinFlagUpdatedEvent>(_onUsePinFlagUpdatedEvent);
    on<DidChangeUsePinFlagEvent>(_onDidChangeUsePinFlagEvent);
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
      final pinKeyboardType = _pinKeyboardTypeRepo.getType();

      emit(
        OnboardingScreenState.common(
          data: data.copyWith(pinKeyboardType: pinKeyboardType),
        ),
      );
    } catch (e) {
      emit(OnboardingScreenState.error(e: e, data: data));
    }
  }

  void _onNextStepEvent(
    OnStepEvent event,
    Emitter<OnboardingScreenState> emit,
  ) {
    emit(OnboardingScreenState.common(data: data.copyWith(step: event.step)));

    if (event.step is OnboardingRelays) {
      relaysSubscription?.cancel();
      relaysSubscription = relaysListRepo.relaysListStream.listen((relays) {
        if (relays.isNotEmpty && data.step is OnboardingRelays) {
          add(const OnboardingScreenEvent.onStep(OnboardingPin()));
        }
      });
    }
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
      event.vm?.setLoading();

      await pinUsecase.execute(pin: event.pin, usePin: event.usePin);

      emit(OnboardingScreenState.didUnlock(data: data));
    } catch (e) {
      event.vm?.setCompleted();
      emit(OnboardingScreenState.error(e: e, data: data));
    }
  }

  void _onGenerateKeyEvent(
    OnGenerateKeyEvent event,
    Emitter<OnboardingScreenState> emit,
  ) {
    final generatedNsec = authUsecase.generateNsecKey();
    emit(
      OnboardingScreenState.common(
        data: data.copyWith(
          step: const OnboardingShowNsec(),
          generatedNsec: generatedNsec,
        ),
      ),
    );
  }

  void _onNsecGeneratedEvent(
    OnNsecGeneratedEvent event,
    Emitter<OnboardingScreenState> emit,
  ) async {
    try {
      emit(OnboardingScreenState.loading(data: data));

      await authUsecase.execute(nsec: event.nsec);

      emit(OnboardingScreenState.common(data: data));
    } catch (e) {
      emit(OnboardingScreenState.error(e: e, data: data));
    }
  }

  void _onRelaysSelectedEvent(
    OnRelaysSelectedEvent event,
    Emitter<OnboardingScreenState> emit,
  ) async {
    try {
      emit(OnboardingScreenState.loading(data: data));

      await relaysListRepo.saveRelaysList(event.relays.toSet());

      emit(
        OnboardingScreenState.common(
          data: data.copyWith(step: const OnboardingPin()),
        ),
      );
    } catch (e) {
      emit(OnboardingScreenState.error(e: e, data: data));
    }
  }

  void _onUsePinFlagUpdatedEvent(
    UsePinFlagUpdatedEvent event,
    Emitter<OnboardingScreenState> emit,
  ) => emit(
    OnboardingScreenState.common(data: data.copyWith(isUsePin: event.isUsePin)),
  );

  void _onDidChangeUsePinFlagEvent(
    DidChangeUsePinFlagEvent event,
    Emitter<OnboardingScreenState> emit,
  ) async {
    final publicKey = authUsecase.currentSession.keys?.publicKey;
    if (publicKey == null || publicKey.isEmpty) {
      return;
    }

    try {
      await _pinEnabledRepo.setForUser(event.isUsePin, pubkey: publicKey);
      emit(
        OnboardingScreenState.common(
          data: data.copyWith(isUsePin: event.isUsePin),
        ),
      );
    } catch (e) {
      emit(OnboardingScreenState.error(e: e, data: data));
    }
  }
}
