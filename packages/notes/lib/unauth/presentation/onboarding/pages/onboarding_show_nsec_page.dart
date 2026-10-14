import 'package:common/app/icons/app_icons.dart';
import 'package:common/presentation/widgets/markdown/gpt_markdown_widget.dart';
import 'package:common/presentation/widgets/onboarding_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/common/presentation/dialogs/backup_password_dialog.dart';
import 'package:nostr_notes/l10n/localization.dart';
import 'package:common/app/theme/sizes.dart';

import '../bloc/onboarding_screen_bloc.dart';
import '../bloc/onboarding_screen_event.dart';

final class OnboardingShowNsecPage extends StatelessWidget {
  const OnboardingShowNsecPage({super.key});

  static final _actionButtonStyle = ButtonStyle(
    minimumSize: const WidgetStatePropertyAll(
      Size.fromHeight(Sizes.buttonHeight),
    ),

    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sizes.radius)),
    ),
  );

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
          Row(
            spacing: Sizes.indent2x,
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _onCopyKey(context, nsec),
                  style: _actionButtonStyle,
                  icon: const Icon(Icons.copy),
                  label: _SingleLineLabel(
                    l10n.onboardingShowNsecPageButtonCopyKey,
                  ),
                ),
              ),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _onSaveToFile(context),
                  style: _actionButtonStyle,
                  icon: const Icon(Icons.save_alt),
                  label: _SingleLineLabel(
                    l10n.onboardingShowNsecPageButtonSaveToFile,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _onSaveToFile(BuildContext context) async {
    final result = await showDialog<BackupPasswordDialogResult>(
      context: context,
      builder: (_) => const BackupPasswordDialog.keysExport(),
    );
    if (result == null || !context.mounted) return;
    context.read<OnboardingScreenBloc>().add(
      OnboardingScreenEvent.saveKeyBackup(
        password: result.password,
        fileName: result.fileName,
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

/// Shrinks instead of wrapping, so both buttons in the row keep one height
/// whatever the translation length.
final class _SingleLineLabel extends StatelessWidget {
  final String text;

  const _SingleLineLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return FittedBox(fit: BoxFit.scaleDown, child: Text(text, maxLines: 1));
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
