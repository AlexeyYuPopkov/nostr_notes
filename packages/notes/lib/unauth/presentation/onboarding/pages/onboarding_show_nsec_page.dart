import 'package:common/app/icons/app_icons.dart';
import 'package:common/presentation/widgets/markdown/gpt_markdown_widget.dart';
import 'package:common/presentation/widgets/onboarding_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/l10n/localization.dart';
import 'package:common/app/theme/sizes.dart';
import 'package:common/presentation/buttons/prymary_button.dart';

import '../bloc/onboarding_screen_bloc.dart';
import '../bloc/onboarding_screen_event.dart';

final class OnboardingShowNsecPage extends StatelessWidget {
  const OnboardingShowNsecPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final bloc = context.read<OnboardingScreenBloc>();
    final nsec = bloc.data.generatedNsec ?? '';

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Center(
            child: OnboardingIcon.asset(
              CommonIcons.nsecIcon,
              semanticsLabel: 'Nsec icon',
            ),
          ),
          const SizedBox(height: Sizes.indentVariant4x),
          Center(
            child: Text(
              l10n.onboardingShowNsecPageTitle,
              style: theme.textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: Sizes.indentVariant4x),
          Center(
            child: Text(
              l10n.onboardingShowNsecPageDescription,
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
                GptMarkdownWidget(md: l10n.onboardingShowNsecPageOptionMD1),
                GptMarkdownWidget(md: l10n.onboardingShowNsecPageOptionMD2),
                GptMarkdownWidget(md: l10n.onboardingShowNsecPageOptionMD3),
              ],
            ),
          ),
          const SizedBox(height: Sizes.indent4x),
          _NsecCard(nsec: nsec),
          const SizedBox(height: Sizes.indent4x),
          const SizedBox(height: Sizes.indent4x),
          Center(
            child: PrymaryButton(
              title: l10n.onboardingShowNsecPageButtonCopyKey,
              onTap: () => _onCopyKey(context, nsec),
            ),
          ),
        ],
      ),
    );
  }

  void _onCopyKey(BuildContext context, String nsec) {
    Clipboard.setData(ClipboardData(text: nsec));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.onboardingShowNsecPageKeyCopied),
        duration: const Duration(seconds: 2),
      ),
    );
    context.read<OnboardingScreenBloc>().add(
      OnboardingScreenEvent.onNsecGenerated(nsec),
    );
  }
}

// final class _Option extends StatelessWidget {
//   final String md;
//   const _Option({required this.md});

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return MarkdownBody(
//       shrinkWrap: true,
//       data: md,
//       styleSheet: MarkdownStyleSheet(
//         pPadding: EdgeInsets.zero,
//         p: theme.textTheme.bodyLarge,
//         textAlign: WrapAlignment.start,
//       ),
//     );
//   }
// }

final class _NsecCard extends StatelessWidget {
  final String nsec;
  const _NsecCard({required this.nsec});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Sizes.indent2x),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(Sizes.radius),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: SelectableText(
        nsec,
        style: theme.textTheme.bodyMedium?.copyWith(fontFamily: 'monospace'),
        textAlign: TextAlign.center,
      ),
    );
  }
}
