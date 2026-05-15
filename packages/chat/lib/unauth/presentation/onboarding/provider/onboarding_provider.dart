import 'dart:async';

import 'package:chat/common/domain/usecase/auth_usecase.dart';
import 'package:common/domain/repo/relays_list_repo.dart';
import 'package:common/presentation/buttons/vm/loading_button_vm.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';

import 'onboarding_data.dart';
import 'onboarding_state.dart';
import '../pages/onboarding_screen_step.dart';

part 'onboarding_provider.g.dart';

final class NsecPageVm extends ChangeNotifier {
  bool isLoginMode = true;

  void toggleMode() {
    isLoginMode = !isLoginMode;
    notifyListeners();
  }
}

@riverpod
final class OnboardingProvider extends _$OnboardingProvider {
  late final nsecPageVm = NsecPageVm();
  late final AuthUsecase authUsecase = GetIt.I.get();
  late final RelaysListRepo relaysListRepo = GetIt.I.get();
  StreamSubscription? sessionSubscription;

  OnboardingData get _data => state.data;

  @override
  OnboardingState build() {
    _setupSubscriptions();
    ref.onDispose(() {
      sessionSubscription?.cancel();
      sessionSubscription = null;
      nsecPageVm.dispose();
    });
    return OnboardingCommon(data: OnboardingData.initial());
  }

  void _setupSubscriptions() {
    sessionSubscription?.cancel();
    sessionSubscription = null;
    sessionSubscription =
        Rx.combineLatest2(
          authUsecase.session.distinct((a, b) => a.isAuth == b.isAuth),
          relaysListRepo.relaysListStream,
          (a, b) => (a, b),
        ).listen((data) {
          final session = data.$1;
          final relays = data.$2;
          if (session.isAuth) {
            if (relays.isEmpty) {
              state = OnboardingCommon(
                data: _data.copyWith(step: const OnboardingRelays()),
              );
              return;
            } else {
              state = OnboardingDone(data: _data);
              return;
            }
          } else {
            state = OnboardingCommon(
              data: _data.copyWith(step: const OnboardingWelcome()),
            );
          }
        });
  }

  void onStep(OnboardingStep step) {
    state = OnboardingCommon(data: _data.copyWith(step: step));
  }

  Future<void> onNsec(String nsec, LoadingButtonVM vm) async {
    vm.setLoading();
    try {
      state = OnboardingLoading(data: _data);
      await authUsecase.execute(nsec: nsec);
      vm.setCompleted();
    } catch (e) {
      state = OnboardingError(data: _data, error: e);
      vm.setCompleted();
    }
  }

  void onGenerateKey() {
    final nsec = authUsecase.generateNsecKey();
    state = OnboardingCommon(
      data: _data.copyWith(
        generatedNsec: nsec,
        step: const OnboardingShowNsec(),
      ),
    );
  }

  Future<void> onNsecGenerated(String nsec) async {
    try {
      state = OnboardingLoading(data: _data);
      await authUsecase.execute(nsec: nsec);
    } catch (e) {
      state = OnboardingError(data: _data, error: e);
    }
  }

  void onRelaysDone() {
    state = OnboardingDone(data: _data);
  }
}
