part of 'export_import_screen.dart';

final class _ImportAlertContent extends StatefulWidget {
  const _ImportAlertContent();

  @override
  State<_ImportAlertContent> createState() => _ImportAlertContentState();
}

final class _ImportAlertContentState extends State<_ImportAlertContent> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_ImportAlertFormState');
  late final _passwordController = TextEditingController();
  ImportPolicy _policy = const ImportPolicy.mergeContent();

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
      title: Text(l10n.exportImportImportDialogTitle),
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
              RadioGroup<ImportPolicy>(
                groupValue: _policy,
                onChanged: (v) => setState(() => _policy = v!),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _PolicyRadio(
                      value: const ImportPolicy.mergeContent(),
                      title: l10n.exportImportImportPolicyMergeTitle,
                      subtitle: l10n.exportImportImportPolicyMergeSubtitle,
                    ),
                    _PolicyRadio(
                      value: const ImportPolicy.keepIncoming(),
                      title: l10n.exportImportImportPolicyKeepIncomingTitle,
                      subtitle:
                          l10n.exportImportImportPolicyKeepIncomingSubtitle,
                    ),
                    _PolicyRadio(
                      value: const ImportPolicy.keepExisting(),
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
                validator: null,
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

  void _onConfirm() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(
      context,
    ).pop((password: _passwordController.text.trim(), policy: _policy));
  }
}

final class _PolicyRadio extends StatelessWidget {
  final ImportPolicy value;
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
    return RadioListTile<ImportPolicy>(
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
