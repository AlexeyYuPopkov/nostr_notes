import 'package:common/app/theme/sizes.dart';
import 'package:common/l10n/localization.dart';
import 'package:common/presentation/dialogs/common_tooltip.dart';
import 'package:common/presentation/dialogs/dialog_button.dart';
import 'package:common/presentation/dialogs/dialog_helper.dart';

import 'package:common/presentation/widgets/onboarding_text_field.dart';
import 'package:common/presentation/widgets/progress_hud/progress_hud.dart';
import 'package:common/presentation/widgets/settings_item_tile.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/app/router/app_route/route_handler.dart';
import 'package:nostr_notes/auth/domain/usecase/export_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/import_usecase.dart';
import 'package:nostr_notes/auth/presentation/settings/export_import/bloc/export_import_bloc.dart';
import 'package:nostr_notes/auth/presentation/settings/export_import/bloc/export_import_state.dart';
import 'package:nostr_notes/auth/presentation/settings/settings/settings_screen_routes.dart';
import 'package:nostr_notes/l10n/localization.dart';
import 'package:share_plus/share_plus.dart';

import 'bloc/export_import_event.dart';

final class ExportImportScreen extends StatelessWidget {
  const ExportImportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProgressHudWidgetContent(
      child: BlocProvider(
        create: (_) => ExportImportBloc(),
        child: const _ExportImportView(),
      ),
    );
  }
}

final class _ExportImportView extends StatelessWidget
    with DialogHelper, _PassAlert {
  const _ExportImportView();

  void _listener(BuildContext context, ExportImportState state) async {
    ProgressHud.of(context)?.setLoading(isLoading: state is LoadingState);

    final l10n = context.l10n;

    switch (state) {
      case SuccessState(:final filePath):
        await SharePlus.instance.share(ShareParams(files: [XFile(filePath)]));
      case ImportSuccessState():
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.exportImportImportSuccess)));

        RouteHandler.of(context)?.onRoute(const CloseSettingsRoute(), context);
      case ErrorState(:final error):
        await showError(
          context,
          error: error,
          messageBuilder: (err) => _errorMessage(l10n, err),
        );
      case IdleState():
        break;
      case LoadingState():
        break;
    }
  }

  String? _errorMessage(Localization l10n, Object? error) {
    return switch (error) {
      ExportError(:final payload) => switch (payload) {
        ExportErrorType.noNotes => l10n.exportImportExportEmptyError,
        ExportErrorType.encryptionFailed =>
          l10n.exportImportExportEncryptionError,
        ExportErrorType.fileWriteFailed => l10n.exportImportExportFileError,
        ExportErrorType.unknown => null,
      },
      ImportError(:final payload) => switch (payload) {
        ImportErrorType.invalidFile => l10n.exportImportImportInvalidFileError,
        ImportErrorType.wrongPassword =>
          l10n.exportImportImportWrongPasswordError,
        ImportErrorType.notAuthenticated => l10n.exportImportImportAuthError,
        ImportErrorType.unknown => null,
      },
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocConsumer<ExportImportBloc, ExportImportState>(
      listener: _listener,
      builder: (context, state) {
        final isLoading = state is LoadingState;

        return Scaffold(
          appBar: AppBar(title: Text(l10n.exportImportScreenTitle)),
          body: SafeArea(
            child: ListView(
              children: [
                SettingsItemTile(
                  title: Text(l10n.exportImportItemExportTitle),
                  subtitle: l10n.exportImportItemExportSubtitle,
                  sectionTitle: l10n.exportImportSectionDataTitle,
                  position: .first,
                  trailing: const Icon(Icons.upload, size: Sizes.iconMedium),
                  onTap: isLoading ? null : () => _onExportTap(context),
                ),
                SettingsItemTile(
                  title: Text(l10n.exportImportItemImportTitle),
                  subtitle: l10n.exportImportItemImportSubtitle,
                  position: .last,
                  trailing: const Icon(Icons.download, size: Sizes.iconMedium),
                  onTap: isLoading ? null : () => _onImportTap(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

mixin _PassAlert {
  Future<void> _onExportTap(BuildContext context) async {
    await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) =>
          _AlertContent(onContinue: (str) => _onContinueTap(context, str)),
    );
  }

  void _onContinueTap(BuildContext context, String password) => context
      .read<ExportImportBloc>()
      .add(ExportImportEvent.export(password: password));

  Future<void> _onImportTap(BuildContext context) async {
    final result = await showDialog<({String password, ImportPolicy policy})>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const _ImportAlertContent(),
    );
    if (result == null) return;

    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );
    final path = file?.path;
    if (path == null) {
      return;
    }

    if (context.mounted) {
      context.read<ExportImportBloc>().add(
        ExportImportEvent.import(
          filePath: path,
          password: result.password,
          policy: result.policy,
        ),
      );
    }
  }
}

final class _AlertContent extends StatefulWidget {
  final ValueChanged<String>? onContinue;
  const _AlertContent({required this.onContinue});

  @override
  State<_AlertContent> createState() => _AlertContentState();
}

final class _AlertContentState extends State<_AlertContent> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_PassAlertFormState');

  late final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
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
              controller: controller,
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
          onPressed: _onContinueTap,
        ),
      ],
    );
  }

  void _onContinueTap() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onContinue?.call(controller.text.trim());
      Navigator.of(context).pop();
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

// ---------------------------------------------------------------------------
// Import dialog
// ---------------------------------------------------------------------------

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

    return AppAlertDialog(
      title: Text(l10n.exportImportImportDialogTitle),
      content: Form(
        key: _formKey,
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
                    subtitle: l10n.exportImportImportPolicyKeepIncomingSubtitle,
                  ),
                  _PolicyRadio(
                    value: const ImportPolicy.keepExisting(),
                    title: l10n.exportImportImportPolicyKeepExistingTitle,
                    subtitle: l10n.exportImportImportPolicyKeepExistingSubtitle,
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
