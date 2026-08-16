import 'package:chat/l10n/localization.dart';
import 'package:common/app/icons/app_icons.dart';
import 'package:common/app/theme/sizes.dart';
import 'package:common/presentation/buttons/prymary_button.dart';
import 'package:common/presentation/widgets/markdown/gpt_markdown_widget.dart';
import 'package:common/presentation/widgets/onboarding_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/onboarding_provider.dart';
import 'onboarding_screen_step.dart';

final class OnboardingWelcomePage extends ConsumerWidget {
  const OnboardingWelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Center(
            child: OnboardingIcon.asset(
              CommonIcons.nostrIcon,
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
          const SizedBox(height: Sizes.indentVariant4x),
          Center(
            child: Text(
              l10n.onboardingWelcomePageDescription,
              style: theme.textTheme.titleSmall,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: Sizes.indentVariant4x),
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                GptMarkdownWidget(md: l10n.onboardingWelcomePageOptionMD1),
                GptMarkdownWidget(md: l10n.onboardingWelcomePageOptionMD2),
                GptMarkdownWidget(md: l10n.onboardingWelcomePageOptionMD3),
                GptMarkdownWidget(md: l10n.onboardingWelcomePageOptionMD4),
              ],
            ),
          ),
          const SizedBox(height: Sizes.indent4x),
          const SizedBox(height: Sizes.indent4x),
          Center(
            child: PrymaryButton(
              title: l10n.onboardingWelcomeButtonNext,
              onTap: () => _onNext(ref),
            ),
          ),
          const SizedBox(height: Sizes.indent2x),
          Center(
            child: CupertinoButton(
              onPressed: () => _onHelp(context),
              child: Text(
                l10n.onboardingWelcomeButtonHelp,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onNext(WidgetRef ref) {
    ref
        .read(onboardingProviderProvider.notifier)
        .onStep(const OnboardingNsec());
  }

  void _onHelp(BuildContext context) {
    // TODO: show help dialog
  }
}
