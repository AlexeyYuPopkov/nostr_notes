import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/app/l10n/localization.dart';
import 'package:nostr_notes/app/sizes.dart';
import 'package:nostr_notes/common/presentation/buttons/prymary_button.dart';

import '../bloc/onboarding_screen_bloc.dart';
import '../bloc/onboarding_screen_event.dart';

final class OnboardingWelcomePage extends StatelessWidget {
  const OnboardingWelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.all(Sizes.indent2x),
      child: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    l10n.onboardingWelcomePageTitle,
                    style: theme.textTheme.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: Sizes.indent2x),
                Center(
                  child: Text(
                    l10n.onboardingWelcomePageDescription,
                    style: theme.textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: Sizes.indent2x),
                _Option.fromString(
                  l10n.onboardingWelcomePageOptionComponents1,
                ),
                _Option.fromString(
                  l10n.onboardingWelcomePageOptionComponents2,
                ),
                _Option.fromString(
                  l10n.onboardingWelcomePageOptionComponents3,
                ),
                _Option.fromString(
                  l10n.onboardingWelcomePageOptionComponents4,
                ),
                const SizedBox(height: Sizes.indent4x),
                const SizedBox(height: Sizes.indent4x),
                Center(
                  child: PrymaryButton(
                    title: l10n.commonButtonContinue,
                    onTap: () => _onNext(context),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onNext(BuildContext context) => context
      .read<OnboardingScreenBloc>()
      .add(const OnboardingScreenEvent.nextStep());
}

final class _Option extends StatelessWidget {
  final List<String> components;
  const _Option({required this.components});

  factory _Option.fromString(String components) {
    return _Option(components: components.split('; '));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    assert(components.length >= 2);
    if (components.length < 2) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Sizes.indent2x),
      child: Text.rich(
        style: theme.textTheme.bodyLarge,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        TextSpan(
          children: [
            TextSpan(text: components[0]),
            const TextSpan(text: ' '),
            TextSpan(
              text: components[1],
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const TextSpan(text: ' '),
            TextSpan(text: components[2]),
          ],
        ),
      ),
    );
  }
}

// "onboardingWelcomePageTitle": "Welcome to NotesVault",
// "onboardingWelcomePageDescription": "Securely store short notes and passwords – encrypted, decentralized, just for you",
// "onboardingWelcomePageOption1": "✏️ Create short notes and passwords",
// "onboardingWelcomePageOption2": "🔐 Encrypted on your device",
// "onboardingWelcomePageOption3": "🌐 Stored via Nostr",
// "onboardingWelcomePageOption4": "🧷 Access with your nsec and PIN"
