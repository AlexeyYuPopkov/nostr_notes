import 'package:common/app/theme/sizes.dart';
import 'package:common/presentation/dialogs/dialog_helper.dart';
import 'package:di_storage/di_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nostr_notes/app/router/app_router_path.dart';

import 'package:nostr_notes/common/domain/usecase/auth_usecase.dart';
import 'package:nostr_notes/unauth/presentation/onboarding/pages/onboarding_step.dart';

import 'bloc/onboarding_screen_bloc.dart';
import 'bloc/onboarding_screen_state.dart';
import 'params/onboarding_screen_params.dart';

final class OnboardingScreen extends StatelessWidget with DialogHelper {
  final OnboardingScreenParams params;

  const OnboardingScreen({super.key, required this.params});

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
    final auth = DiStorage.shared.resolve<AuthUsecase>();
    return Scaffold(
      appBar: params.addAccount
          ? AppBar(
              // The cross is only shown while the current session is still
              // unlocked: at that point nothing has changed yet and the
              // screen can simply be popped. Once the new account's nsec is
              // submitted the session locks and the flow must go forward.
              leading: StreamBuilder(
                stream: auth.session,
                initialData: auth.currentSession,
                builder: (context, snapshot) {
                  if (snapshot.data?.isUnlocked != true) {
                    return const SizedBox.shrink();
                  }
                  return CloseButton(
                    onPressed: () => GoRouter.of(context).pop(),
                  );
                },
              ),
            )
          : null,
      body: FutureBuilder(
        // In add-account mode the current session must stay untouched:
        // restore() would re-lock it from the stored active key.
        future: params.addAccount
            ? Future.value(auth.currentSession)
            : auth.restore(),
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
              initialIndex: params.addAccount
                  ? OnboardingStep.pages.indexOf(const OnboardingNsec())
                  : 0,
              child: BlocProvider(
                create: (context) =>
                    OnboardingScreenBloc(addAccount: params.addAccount),
                child:
                    BlocListener<OnboardingScreenBloc, OnboardingScreenState>(
                      listenWhen: (a, b) => a.data.step != b.data.step,
                      listener: (context, state) {
                        DefaultTabController.of(context).animateTo(
                          OnboardingStep.pages.indexOf(state.data.step),
                        );
                      },
                      child:
                          BlocConsumer<
                            OnboardingScreenBloc,
                            OnboardingScreenState
                          >(
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
                                            padding: const EdgeInsets.all(
                                              Sizes.indent2x,
                                            ),
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
          );
        },
      ),
    );
  }
}
