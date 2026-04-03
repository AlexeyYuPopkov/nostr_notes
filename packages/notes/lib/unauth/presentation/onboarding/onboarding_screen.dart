import 'package:common/app/theme/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nostr_notes/app/router/app_router_path.dart';
import 'package:common/presentation/dialogs/dialog_helper.dart';
import 'package:nostr_notes/unauth/presentation/onboarding/pages/onboarding_step.dart';

import 'bloc/onboarding_screen_bloc.dart';
import 'bloc/onboarding_screen_state.dart';

final class OnboardingScreen extends StatelessWidget with DialogHelper {
  const OnboardingScreen({super.key});

  void _listener(BuildContext context, OnboardingScreenState state) {
    switch (state) {
      case InitialState():
      case CommonState():
      case LoadingState():
        break;
      case ErrorState():
        showError(context, error: state.e);
        break;
      case DidUnlockState():
        GoRouter.of(context).pushReplacementNamed(AppRouterName.home);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: DefaultTabController(
          length: OnboardingStep.pages.length,
          initialIndex: 0,
          child: BlocProvider(
            create: (context) => OnboardingScreenBloc(),
            child: BlocListener<OnboardingScreenBloc, OnboardingScreenState>(
              listenWhen: (a, b) => a.data.step != b.data.step,
              listener: (context, state) {
                DefaultTabController.of(
                  context,
                ).animateTo(OnboardingStep.pages.indexOf(state.data.step));
              },
              child: BlocConsumer<OnboardingScreenBloc, OnboardingScreenState>(
                listener: _listener,
                builder: (context, state) {
                  if (state is InitialState) {
                    final theme = Theme.of(context);
                    return Container(
                      color: theme.colorScheme.surface,
                      child: const Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                    );
                  }
                  return AbsorbPointer(
                    absorbing: state is LoadingState,
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
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
