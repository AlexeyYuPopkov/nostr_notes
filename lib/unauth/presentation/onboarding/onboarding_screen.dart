import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/common/presentation/dialogs/dialog_helper.dart';

import 'bloc/onboarding_screen_bloc.dart';
import 'bloc/onboarding_screen_state.dart';

final class OnboardingScreen extends StatelessWidget with DialogHelper {
  const OnboardingScreen({super.key});

  void _listener(
    BuildContext context,
    OnboardingScreenState state,
  ) {
    switch (state) {
      case CommonState():
        break;
      case LoadingState():
        break;
      case ErrorState():
        showError(context: context, error: state.e);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OnboardingScreenBloc(),
      child: BlocConsumer<OnboardingScreenBloc, OnboardingScreenState>(
        listener: _listener,
        builder: (context, state) {
          return const Scaffold(
            body: Center(
              child: Text('123'),
            ),
          );
        },
      ),
    );
  }
}
