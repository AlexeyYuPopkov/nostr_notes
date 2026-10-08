import 'package:common/app/theme/sizes.dart';
import 'package:common/l10n/localization.dart';
import 'package:common/presentation/dialogs/common_tooltip.dart';
import 'package:common/presentation/dialogs/dialog_button.dart';
import 'package:common/presentation/dialogs/dialog_helper.dart';
import 'package:common/presentation/widgets/onboarding_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nostr_notes/common/domain/usecase/keys_backup/export_keys_usecase.dart';
import 'package:nostr_notes/l10n/localization.dart';

final class BackupPasswordDialogResult {
  final String password;

  /// Null when left blank or when the dialog doesn't ask for one.
  final String? fileName;

  const BackupPasswordDialogResult({required this.password, this.fileName});
}

enum _Purpose { accountsExport, keysExport, keysImport }

/// Asks for a mandatory backup password — for backups that hold usable
/// credentials, so there is no "no password" option like the notes export.
final class BackupPasswordDialog extends StatefulWidget {
  final _Purpose _purpose;

  const BackupPasswordDialog.accountsExport({super.key})
    : _purpose = _Purpose.accountsExport;

  const BackupPasswordDialog.keysExport({super.key})
    : _purpose = _Purpose.keysExport;

  const BackupPasswordDialog.keysImport({super.key})
    : _purpose = _Purpose.keysImport;

  @override
  State<BackupPasswordDialog> createState() => _BackupPasswordDialogState();
}

final class _BackupPasswordDialogState extends State<BackupPasswordDialog> {
  final _formKey = GlobalKey<FormState>(
    debugLabel: '_BackupPasswordDialogState',
  );
  late final _controller = TextEditingController();
  late final _fileNameController = TextEditingController();

  static const _maxFileNameLength = 64;
  static const _accountsMinPasswordLength = 3;

  int get _minPasswordLength => switch (widget._purpose) {
    _Purpose.accountsExport => _accountsMinPasswordLength,
    _Purpose.keysExport ||
    _Purpose.keysImport => ExportKeysUsecase.minPasswordLength,
  };

  bool get _asksFileName => widget._purpose != _Purpose.keysImport;

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
    final (:title, :passwordHint, :warning) = _texts(l10n);
    return AppAlertDialog(
      title: Text(title),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_asksFileName) ...[
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
            ],
            OnboardingTextFormField(
              controller: _controller,
              obscureText: true,
              hint: passwordHint,
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'\s')),
              ],
              validator: _validate,
            ),
            if (warning != null)
              _Warning(title: commonL10n.commonWarning, message: warning),
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

  ({String title, String passwordHint, String? warning}) _texts(
    Localization l10n,
  ) => switch (widget._purpose) {
    _Purpose.accountsExport => (
      title: l10n.accsBackupExportPasswordDialogTitle,
      passwordHint: l10n.accsBackupExportPasswordDialogTextFieldHint,
      warning: l10n.accsBackupExportPasswordRequiredHint,
    ),
    _Purpose.keysExport => (
      title: l10n.keysBackupExportDialogTitle,
      passwordHint: l10n.accsBackupExportPasswordDialogTextFieldHint,
      warning: l10n.keysBackupExportDialogWarning,
    ),
    _Purpose.keysImport => (
      title: l10n.keysBackupImportDialogTitle,
      passwordHint: l10n.accsBackupExportPasswordDialogTextFieldHint,
      warning: null,
    ),
  };

  void _onConfirm() {
    if (_formKey.currentState?.validate() ?? false) {
      final fileName = _fileNameController.text.trim();
      Navigator.of(context).pop(
        BackupPasswordDialogResult(
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

final class _Warning extends StatelessWidget {
  final String title;
  final String message;

  const _Warning({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CommonTooltip(
      title: title,
      message: message,
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
                message,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
