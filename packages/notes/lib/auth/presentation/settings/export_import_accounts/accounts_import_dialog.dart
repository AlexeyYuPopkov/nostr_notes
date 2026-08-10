import 'package:common/app/theme/sizes.dart';
import 'package:common/l10n/localization.dart';
import 'package:common/presentation/dialogs/dialog_button.dart';
import 'package:common/presentation/dialogs/dialog_helper.dart';
import 'package:common/presentation/widgets/onboarding_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nostr_notes/auth/domain/usecase/login_items/import_accounts_usecase.dart';
import 'package:nostr_notes/l10n/localization.dart';

/// Same shape as `_ImportAlertContent` (notes), with two differences: the
/// policy options are [LoginItemImportPolicy] (no "merge" — see that type's
/// doc for why), and the password field is mandatory.
final class AccountsImportDialog extends StatefulWidget {
  const AccountsImportDialog({super.key});

  @override
  State<AccountsImportDialog> createState() => _AccountsImportDialogState();
}

final class _AccountsImportDialogState extends State<AccountsImportDialog> {
  final _formKey = GlobalKey<FormState>(
    debugLabel: '_AccountsImportDialogState',
  );
  late final _passwordController = TextEditingController();
  LoginItemImportPolicy _policy = const LoginItemImportPolicy.keepNewest();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final commonL10n = context.commonL10n;
    final theme = Theme.of(context);
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return AppAlertDialog(
      title: Text(l10n.accsBackupImportDialogTitle),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: Sizes.indent),
                child: Text(
                  l10n.exportImportImportDialogPolicyLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              RadioGroup<LoginItemImportPolicy>(
                groupValue: _policy,
                onChanged: (v) => setState(() => _policy = v!),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _PolicyRadio(
                      value: const LoginItemImportPolicy.keepNewest(),
                      title: l10n.accsBackupImportPolicyKeepNewestTitle,
                      subtitle: l10n.accsBackupImportPolicyKeepNewestSubtitle,
                    ),
                    _PolicyRadio(
                      value: const LoginItemImportPolicy.keepIncoming(),
                      title: l10n.exportImportImportPolicyKeepIncomingTitle,
                      subtitle:
                          l10n.exportImportImportPolicyKeepIncomingSubtitle,
                    ),
                    _PolicyRadio(
                      value: const LoginItemImportPolicy.keepExisting(),
                      title: l10n.exportImportImportPolicyKeepExistingTitle,
                      subtitle:
                          l10n.exportImportImportPolicyKeepExistingSubtitle,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Sizes.indent2x),
              OnboardingTextFormField(
                controller: _passwordController,
                obscureText: true,
                hint: l10n.exportImportImportDialogPasswordFieldHint,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'\s')),
                ],
                validator: _validatePassword,
              ),
              Padding(
                padding: const EdgeInsets.only(top: Sizes.indent),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: Sizes.iconSmall,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: Sizes.indent),
                    Expanded(
                      child: Text(
                        l10n.exportImportImportDialogPasswordHint,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        DialogTextButtonUnderlined(
          text: commonL10n.commonButtonCancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        DialogTextButton(
          text: commonL10n.commonButtonOk,
          onPressed: _onConfirm,
        ),
      ],
    );
  }

  String? _validatePassword(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return context.l10n.accsBackupExportPasswordRequired;
    }
    return null;
  }

  void _onConfirm() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(
      context,
    ).pop((password: _passwordController.text.trim(), policy: _policy));
  }
}

final class _PolicyRadio extends StatelessWidget {
  final LoginItemImportPolicy value;
  final String title;
  final String subtitle;

  const _PolicyRadio({
    required this.value,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RadioListTile<LoginItemImportPolicy>(
      dense: true,
      contentPadding: EdgeInsets.zero,
      value: value,
      title: Text(title, style: theme.textTheme.bodyMedium),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
