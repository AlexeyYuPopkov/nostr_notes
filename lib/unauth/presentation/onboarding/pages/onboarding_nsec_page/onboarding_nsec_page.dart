import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/unauth/presentation/onboarding/pages/onboarding_nsec_page/onboarding_nsec_sign_in.dart';
import 'package:nostr_notes/unauth/presentation/onboarding/pages/onboarding_nsec_page/onboarding_sign_up_page.dart';

import '../../bloc/onboarding_screen_bloc.dart';

final class OnboardingNsecPageVm extends ChangeNotifier {
  bool isLoginMode = true;

  void toggleMode() {
    isLoginMode = !isLoginMode;
    notifyListeners();
  }
}

final class OnboardingNsecPage extends StatelessWidget {
  const OnboardingNsecPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<OnboardingScreenBloc>().nsecPageVm;

    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        return AnimatedCrossFade(
          crossFadeState: vm.isLoginMode
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          duration: const Duration(milliseconds: 300),
          firstChild: const OnboardingNsecSignIn(),
          secondChild: const OnboardingSignUpPage(),
        );
      },
    );
  }
}
