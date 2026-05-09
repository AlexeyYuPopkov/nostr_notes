import 'package:chat/common/domain/usecase/auth_usecase.dart';
import 'package:common/presentation/buttons/vm/loading_button_vm.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'onboarding_data.dart';
import 'onboarding_screen_state.dart';
import 'pages/onboarding_screen_step.dart';

part 'onboarding_state.g.dart';

final class NsecPageVm extends ChangeNotifier {
  bool isLoginMode = true;

  void toggleMode() {
    isLoginMode = !isLoginMode;
    notifyListeners();
  }
}

@riverpod
final class OnboardingState extends _$OnboardingState {
  late final nsecPageVm = NsecPageVm();
  late final AuthUsecase authUsecase = GetIt.I.get();

  OnboardingData get _data => state.data;

  @override
  OnboardingScreenState build() {
    return OnboardingCommon(data: OnboardingData.initial());
  }

  void onStep(OnboardingStep step) {
    state = OnboardingCommon(data: _data.copyWith(step: step));
  }

  Future<void> onNsec(String nsec, LoadingButtonVM vm) async {
    vm.setLoading();
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      vm.setCompleted();
      onStep(const OnboardingRelays());
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

  void onNsecGenerated(String nsec) {
    onStep(const OnboardingRelays());
  }

  void onRelaysDone() {
    state = OnboardingDone(data: _data);
  }
}
