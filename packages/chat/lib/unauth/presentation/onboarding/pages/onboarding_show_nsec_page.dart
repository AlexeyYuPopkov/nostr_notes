import 'package:chat/l10n/localization.dart';
import 'package:common/app/icons/app_icons.dart';
import 'package:common/app/theme/sizes.dart';
import 'package:common/presentation/buttons/prymary_button.dart';
import 'package:common/presentation/widgets/markdown/gpt_markdown_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../provider/onboarding_provider.dart';

final class OnboardingShowNsecPage extends ConsumerWidget {
  const OnboardingShowNsecPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final nsec = ref.watch(
      onboardingProviderProvider.select((s) => s.data.generatedNsec ?? ''),
    );

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: SvgPicture.asset(
              CommonIcons.nsecIcon,
              width: Sizes.iconTitle,
              height: Sizes.iconTitle,
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
              onTap: () => _onCopyKey(context, ref, nsec),
            ),
          ),
        ],
      ),
    );
  }

  void _onCopyKey(BuildContext context, WidgetRef ref, String nsec) {
    Clipboard.setData(ClipboardData(text: nsec));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.onboardingShowNsecPageKeyCopied),
        duration: const Duration(seconds: 2),
      ),
    );
    ref.read(onboardingProviderProvider.notifier).onNsecGenerated(nsec);
  }
}

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
