import 'package:chat/l10n/localization.dart';
import 'package:common/app/icons/app_icons.dart';
import 'package:common/app/theme/sizes.dart';
import 'package:common/presentation/widgets/markdown/gpt_markdown_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../provider/onboarding_provider.dart';

final class OnboardingSignUpPage extends ConsumerWidget {
  const OnboardingSignUpPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: SvgPicture.asset(
              CommonIcons.nostrIcon,
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
              onTap: () => _onGenerateKey(ref),
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
              onPressed: () => _onLogin(ref),
              child: Text(l10n.onboardingSignUpButtonLogin),
            ),
          ),
        ],
      ),
    );
  }

  void _onGenerateKey(WidgetRef ref) {
    ref.read(onboardingStateProvider.notifier).onGenerateKey();
  }

  void _onLogin(WidgetRef ref) {
    ref.read(onboardingStateProvider.notifier).nsecPageVm.toggleMode();
  }
}

final class _Option extends StatelessWidget {
  final String md;
  const _Option({required this.md});

  @override
  Widget build(BuildContext context) {
    return GptMarkdownWidget(md: md);
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
