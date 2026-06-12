import 'package:common/app/theme/sizes.dart';
import 'package:common/l10n/localization.dart';
import 'package:common/presentation/dialogs/common_tooltip.dart';
import 'package:common/presentation/dialogs/dialog_button.dart';
import 'package:common/presentation/dialogs/dialog_helper.dart';
import 'package:common/presentation/widgets/onboarding_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nostr_notes/l10n/localization.dart';

/// Password dialog for export. Pops with the entered password string,
/// or `null` if the user cancelled. An empty string means no password.
final class ExportPasswordDialog extends StatefulWidget {
  const ExportPasswordDialog({super.key});

  @override
  State<ExportPasswordDialog> createState() => _ExportPasswordDialogState();
}

final class _ExportPasswordDialogState extends State<ExportPasswordDialog> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_ExportPasswordDialogState');
  late final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final commonL10n = context.commonL10n;
    final theme = Theme.of(context);
    return AppAlertDialog(
      title: Text(l10n.exportImportPasswordDialogTitle),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OnboardingTextFormField(
              controller: _controller,
              obscureText: true,
              hint: l10n.exportImportPasswordDialogTextFieldHint,
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'\s')),
              ],
              validator: _validate,
            ),
            CommonTooltip(
              title: commonL10n.commonWarning,
              message: l10n.exportImportNoPasswordWarning,
              padding: const EdgeInsets.all(Sizes.indent2x),
              child: Padding(
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
                        l10n.exportImportPasswordDialogHint,
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
      Navigator.of(context).pop(_controller.text.trim());
    }
  }

  String? _validate(String? value) {
    if (value == null || value.isEmpty) return null;
    const minPasswordLength = 3;
    if (value.length < minPasswordLength) {
      return context.l10n.exportImportPasswordTooShort(
        minPasswordLength.toString(),
      );
    }
    return null;
  }
}
