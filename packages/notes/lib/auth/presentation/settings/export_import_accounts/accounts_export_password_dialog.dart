import 'package:common/app/theme/sizes.dart';
import 'package:common/l10n/localization.dart';
import 'package:common/presentation/dialogs/common_tooltip.dart';
import 'package:common/presentation/dialogs/dialog_button.dart';
import 'package:common/presentation/dialogs/dialog_helper.dart';
import 'package:common/presentation/widgets/onboarding_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nostr_notes/l10n/localization.dart';

final class AccountsExportPasswordDialogResult {
  final String password;
  final String? fileName;

  const AccountsExportPasswordDialogResult({
    required this.password,
    this.fileName,
  });
}

/// Same shape as `ExportPasswordDialog` (notes), but the password field is
/// mandatory: an account backup contains real login passwords, so — unlike
/// a notes backup — there is no "export unencrypted" option to warn about.
final class AccountsExportPasswordDialog extends StatefulWidget {
  const AccountsExportPasswordDialog({super.key});

  @override
  State<AccountsExportPasswordDialog> createState() =>
      _AccountsExportPasswordDialogState();
}

final class _AccountsExportPasswordDialogState
    extends State<AccountsExportPasswordDialog> {
  final _formKey = GlobalKey<FormState>(
    debugLabel: '_AccountsExportPasswordDialogState',
  );
  late final _controller = TextEditingController();
  late final _fileNameController = TextEditingController();

  static const _maxFileNameLength = 64;
  static const _minPasswordLength = 3;

  @override
  void dispose() {
    _controller.dispose();
    _fileNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final commonL10n = context.commonL10n;
    final theme = Theme.of(context);
    return AppAlertDialog(
      title: Text(l10n.accsBackupExportPasswordDialogTitle),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OnboardingTextFormField(
              controller: _fileNameController,
              hint: l10n.exportImportExportFileNameHint,
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'[\\/:*?"<>|]')),
                LengthLimitingTextInputFormatter(_maxFileNameLength),
              ],
              validator: _validateFileName,
            ),
            const SizedBox(height: Sizes.indent2x),
            OnboardingTextFormField(
              controller: _controller,
              obscureText: true,
              hint: l10n.accsBackupExportPasswordDialogTextFieldHint,
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'\s')),
              ],
              validator: _validate,
            ),
            CommonTooltip(
              title: commonL10n.commonWarning,
              message: l10n.accsBackupExportPasswordRequiredHint,
              padding: const EdgeInsets.all(Sizes.indent2x),
              child: Padding(
                padding: const EdgeInsets.only(top: Sizes.indent),
                child: Row(
                  spacing: Sizes.indent,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: Sizes.iconSmall,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    Expanded(
                      child: Text(
                        l10n.accsBackupExportPasswordRequiredHint,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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

  void _onConfirm() {
    if (_formKey.currentState?.validate() ?? false) {
      final fileName = _fileNameController.text.trim();
      Navigator.of(context).pop(
        AccountsExportPasswordDialogResult(
          password: _controller.text.trim(),
          fileName: fileName.isEmpty ? null : fileName,
        ),
      );
    }
  }

  String? _validate(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return context.l10n.accsBackupExportPasswordRequired;
    }
    if (trimmed.length < _minPasswordLength) {
      return context.l10n.exportImportPasswordTooShort(
        _minPasswordLength.toString(),
      );
    }
    return null;
  }

  /// Optional. When provided, the name must contain at least one usable
  /// character (not only dots/spaces) — the rest is sanitized downstream.
  String? _validateFileName(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return null;
    final hasUsableChar = trimmed.replaceAll(RegExp(r'[.\s]'), '').isNotEmpty;
    if (!hasUsableChar) {
      return context.l10n.exportImportExportFileNameInvalid;
    }
    return null;
  }
}
