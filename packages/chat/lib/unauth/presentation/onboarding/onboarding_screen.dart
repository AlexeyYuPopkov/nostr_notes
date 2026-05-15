import 'package:auto_route/auto_route.dart';
import 'package:chat/common/domain/usecase/auth_usecase.dart';
import 'package:chat/router/app_router.gr.dart';
import 'package:chat/unauth/presentation/onboarding/provider/onboarding_state.dart';
import 'package:chat/unauth/presentation/onboarding/pages/onboarding_screen_step.dart';
import 'package:common/app/theme/sizes.dart';
import 'package:common/presentation/dialogs/dialog_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import 'provider/onboarding_provider.dart';

@RoutePage()
final class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = GetIt.I.get<AuthUsecase>();
    return Scaffold(
      body: FutureBuilder(
        future: auth.restore(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container(
              color: Theme.of(context).colorScheme.surface,
              child: const Center(child: CircularProgressIndicator.adaptive()),
            );
          }
          return SafeArea(
            child: DefaultTabController(
              length: OnboardingStep.pages.length,
              initialIndex: 0,
              child: const _OnboardingBody(),
            ),
          );
        },
      ),
    );
  }
}

final class _OnboardingBody extends ConsumerWidget with DialogHelper {
  const _OnboardingBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<OnboardingState>(onboardingProviderProvider, (prev, next) {
      if (prev?.data.step != next.data.step) {
        final index = OnboardingStep.pages.indexOf(next.data.step);
        if (index >= 0) {
          DefaultTabController.of(context).animateTo(index);
        }
      }

      if (next is OnboardingError) {
        showError(context, error: next.error);
      }

      if (next is OnboardingDone) {
        context.replaceRoute(const HomeRoute());
      }
    });

    final state = ref.watch(onboardingProviderProvider);

    return AbsorbPointer(
      absorbing: state is OnboardingLoading,
      child: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        children: [
          for (final page in OnboardingStep.pages)
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: Sizes.webMaxWidth),
                child: Padding(
                  padding: const EdgeInsets.all(Sizes.indent2x),
                  child: page.build(context),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
