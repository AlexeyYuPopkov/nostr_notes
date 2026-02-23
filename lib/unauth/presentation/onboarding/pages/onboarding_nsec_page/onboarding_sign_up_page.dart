import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nostr_notes/app/icons/app_icons.dart';
import 'package:nostr_notes/app/l10n/localization.dart';
import 'package:nostr_notes/app/sizes.dart';

import '../../bloc/onboarding_screen_bloc.dart';
import '../../bloc/onboarding_screen_event.dart';

final class OnboardingSignUpPage extends StatelessWidget {
  const OnboardingSignUpPage({super.key});

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
              l10n.onboardingSignUpPageTitle,
              style: theme.textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: Sizes.indentVariant4x),
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _Option(md: l10n.onboardingSignUpPageOptionMD1),
                _Option(md: l10n.onboardingSignUpPageOptionMD2),
                _Option(md: l10n.onboardingSignUpPageOptionMD3),
              ],
            ),
          ),
          const SizedBox(height: Sizes.indent4x),
          const SizedBox(height: Sizes.indent4x),
          Center(
            child: _OutlinedButton(
              icon: '🚀',
              title: l10n.onboardingSignUpButtonGenerateKey,
              onTap: () => _onGenerateKey(context),
            ),
          ),
          const SizedBox(height: Sizes.indent4x),
          Center(
            child: Text(
              l10n.onboardingSignUpAlreadyHaveAccount,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: Sizes.indent2x),
          Center(
            child: TextButton(
              onPressed: () => _onLogin(context),
              child: Text(l10n.onboardingSignUpButtonLogin),
            ),
          ),
        ],
      ),
    );
  }

  void _onGenerateKey(BuildContext context) {
    context.read<OnboardingScreenBloc>().add(
      const OnboardingScreenEvent.onGenerateKey(),
    );
  }

  void _onLogin(BuildContext context) {
    final vm = context.read<OnboardingScreenBloc>().nsecPageVm;
    vm.toggleMode();
  }
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

final class _OutlinedButton extends StatelessWidget {
  final String icon;
  final String title;
  final VoidCallback? onTap;

  const _OutlinedButton({required this.icon, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: Sizes.indent4x,
          vertical: Sizes.indentVariant2x,
        ),
        side: BorderSide(color: theme.colorScheme.outline),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Sizes.indent2x),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: Sizes.indent2x),
          Text(title, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}
