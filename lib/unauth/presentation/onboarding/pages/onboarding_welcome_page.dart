import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nostr_notes/app/icons/app_icons.dart';
import 'package:nostr_notes/app/l10n/localization.dart';
import 'package:nostr_notes/app/sizes.dart';
import 'package:nostr_notes/common/presentation/buttons/prymary_button.dart';
import 'package:nostr_notes/unauth/presentation/onboarding/pages/onboarding_step.dart';

import '../bloc/onboarding_screen_bloc.dart';
import '../bloc/onboarding_screen_event.dart';

final class OnboardingWelcomePage extends StatelessWidget {
  const OnboardingWelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: SvgPicture.asset(
              AppIcons.welcomeIcon,
              width: Sizes.iconTitle,
              height: Sizes.iconTitle,
              semanticsLabel: 'Nostr icon',
            ),
          ),
          const SizedBox(height: Sizes.indentVariant4x),
          Center(
            child: Text(
              l10n.onboardingWelcomePageTitle,
              style: theme.textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
          ),
          // const SomeFuncWidget(),
          const SizedBox(height: Sizes.indentVariant4x),
          Center(
            child: Text(
              l10n.onboardingWelcomePageDescription,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: Sizes.indentVariant4x),
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _Option(md: l10n.onboardingWelcomePageOptionMD1),
                _Option(md: l10n.onboardingWelcomePageOptionMD2),
                _Option(md: l10n.onboardingWelcomePageOptionMD3),
                _Option(md: l10n.onboardingWelcomePageOptionMD4),
              ],
            ),
          ),
          const SizedBox(height: Sizes.indent4x),
          const SizedBox(height: Sizes.indent4x),
          Center(
            child: PrymaryButton(
              title: l10n.onboardingWelcomeButtonNext,
              onTap: () => _onNext(context),
            ),
          ),
        ],
      ),
    );
  }

  void _onNext(BuildContext context) => context
      .read<OnboardingScreenBloc>()
      .add(const OnboardingScreenEvent.onStep(OnboardingNsec()));
}

final class _Option extends StatelessWidget {
  final String md;
  const _Option({required this.md});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MarkdownBody(
      shrinkWrap: true,
      data: md,
      styleSheet: MarkdownStyleSheet(
        pPadding: EdgeInsets.zero,
        p: theme.textTheme.bodyLarge,
        textAlign: WrapAlignment.start,
      ),
    );
  }
}
