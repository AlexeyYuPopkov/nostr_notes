import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/onboarding_provider.dart';
import 'onboarding_nsec_sign_in.dart';
import 'onboarding_sign_up_page.dart';

final class OnboardingNsecPage extends ConsumerWidget {
  const OnboardingNsecPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.read(onboardingProviderProvider.notifier).nsecPageVm;

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
