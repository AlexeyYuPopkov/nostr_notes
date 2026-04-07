import 'package:auto_route/auto_route.dart';
import 'package:chat/unauth/onboarding/provider/pages/onboarding_screen_step.dart';
import 'package:common/app/theme/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'provider/onboarding_state.dart';

@RoutePage()
final class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ignore: unused_local_variable
    final provider = ref.watch(onboardingStateProvider);

    return Scaffold(
      body: SafeArea(
        child: DefaultTabController(
          length: OnboardingStep.pages.length,
          initialIndex: 0,
          child: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (final page in OnboardingStep.pages)
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: Sizes.webMaxWidth,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(Sizes.indent2x),
                      child: page.build(context),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
