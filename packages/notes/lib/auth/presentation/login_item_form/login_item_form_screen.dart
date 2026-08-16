import 'dart:async';

import 'package:common/app/theme/sizes.dart';
import 'package:common/l10n/localization.dart';
import 'package:common/presentation/dialogs/dialog_helper.dart';
import 'package:common/presentation/widgets/common_popup_menu_button.dart';
import 'package:common/presentation/widgets/progress_hud/progress_hud.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/auth/domain/model/login_item.dart';
import 'package:nostr_notes/auth/domain/usecase/login_items/export_accounts_usecase.dart';
import 'package:nostr_notes/auth/presentation/settings/export_import_accounts/accounts_export_password_dialog.dart';
import 'package:nostr_notes/auth/presentation/login_item_form/widgets/login_item_go_icon.dart';
import 'package:nostr_notes/auth/presentation/tools/clipboard_helper.dart';
import 'package:nostr_notes/auth/presentation/tools/share_file_helper.dart';
import 'package:nostr_notes/l10n/localization.dart';

import 'bloc/login_item_details_params.dart';
import 'bloc/login_item_form_bloc.dart';
import 'bloc/login_item_form_event.dart';
import 'bloc/login_item_form_state.dart';
import 'tools/login_item_form_formatters.dart';
import 'widgets/login_item_form_gen_pass.dart';
import 'widgets/login_item_form_header.dart';
import 'widgets/login_item_form_password_strength.dart';
import 'widgets/login_item_form_text_field.dart';

abstract interface class LoginItemFormScreenCoordinator {
  FutureOr<dynamic> onRawEventRoute(
    BuildContext context, {
    required String eventId,
  });
}

final class LoginItemFormScreen extends StatelessWidget
    with DialogHelper, ShareFileHelper {
  final LoginItemDetailsParams params;
  final LoginItemFormScreenCoordinator coordinator;

  const LoginItemFormScreen({
    super.key,
    required this.params,
    required this.coordinator,
  });

  void _listener(BuildContext context, LoginItemFormState state) {
    final hud = ProgressHud.of(context);
    hud?.setLoading(isLoading: state is LoadingState);

    switch (state) {
      case CommonState():
      case LoadingState():
      case DidGenPassAppearState():
        break;
      case ErrorState():
        showError(
          context,
          error: state.e,
          messageBuilder: (err) => _errorMessage(context.l10n, err),
        );
        break;
      case DidSaveState():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.accsFormSaveSuccess)),
        );
        Navigator.of(context).pop();
        break;
      case DidDeleteState():
        Navigator.of(context).pop();
        break;
      case WillExportState():
        _onExport(context);
        break;
      case ExportSuccessState(:final filePath, :final bytes, :final fileName):
        shareFile(
          filePath,
          bytes,
          fileName,
          context,
          successMessage: (l10n) => l10n.accsBackupExportSuccess,
        );
        break;
    }
  }

  String? _errorMessage(Localization l10n, Object? error) {
    return switch (error) {
      ExportAccountsError(:final payload) => switch (payload) {
        ExportAccountsErrorType.noAccounts => l10n.accsBackupExportEmptyError,
        ExportAccountsErrorType.passwordRequired =>
          l10n.accsBackupExportPasswordRequired,
        ExportAccountsErrorType.encryptionFailed =>
          l10n.exportImportExportEncryptionError,
        ExportAccountsErrorType.fileWriteFailed =>
          l10n.exportImportExportFileError,
        ExportAccountsErrorType.unknown => null,
      },
      _ => null,
    };
  }

  Future<void> _onExport(BuildContext context) async {
    final result = await showDialog<AccountsExportPasswordDialogResult>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const AccountsExportPasswordDialog(),
    );
    if (result == null || !context.mounted) return;
    context.read<LoginItemFormBloc>().add(
      LoginItemFormEvent.export(
        password: result.password,
        fileName: result.fileName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProgressHudWidgetContent(
      child: BlocProvider(
        create: (context) => LoginItemFormBloc(pathParams: params),
        child: BlocConsumer<LoginItemFormBloc, LoginItemFormState>(
          listener: _listener,
          builder: (context, state) {
            final bloc = context.read<LoginItemFormBloc>();
            final isLoading = state is LoadingState;
            final readonly = state.data.readonly;
            final item = state.data.initialItem.value;

            return Scaffold(
              body: AbsorbPointer(
                absorbing: isLoading,
                child: CustomScrollView(
                  // Bouncing physics on both platforms so the app bar's
                  // overscroll stretch is actually reachable.
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: [
                    LoginItemFormHeader(
                      titleController: bloc.titleController,
                      websiteController: bloc.websiteController,
                      title: Text(
                        readonly
                            ? context.l10n.accsTabTitle
                            : context.l10n.accsAddTitle,
                      ),
                      actions: [
                        if (readonly && item != null)
                          _MoreButton(coordinator: coordinator, item: item),
                        const _TrailingAppbarButton(),
                        const SizedBox(width: Sizes.indent2x),
                      ],
                    ),
                    SliverSafeArea(
                      top: false,
                      sliver: SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Sizes.indent,
                          vertical: Sizes.indent2x,
                        ),
                        sliver: SliverList.list(
                          children: [
                            LoginItemFormTextField(
                              controller: bloc.titleController,
                              label: context.l10n.accsFormTitleLabel,
                              hint: context.l10n.accsFormTitleHint,
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.next,
                              enabled: !readonly,
                              position: .first,
                              inputFormatters: LoginItemFormFormatters.title,
                            ),

                            LoginItemFormTextField(
                              controller: bloc.websiteController,
                              label: context.l10n.accsFormWebsiteLabel,
                              hint: context.l10n.accsFormWebsiteHint,
                              keyboardType: TextInputType.url,
                              textInputAction: TextInputAction.next,
                              enabled: !readonly,
                              position: .middle,
                              inputFormatters: LoginItemFormFormatters.website,
                              autofillHints: const [AutofillHints.url],
                              trailing: LoginItemGoIcon(
                                url: bloc.websiteController.text.trim(),
                                username: bloc.usernameController.text.trim(),
                                password: bloc.passwordController.text.trim(),
                              ),
                            ),

                            LoginItemFormTextField(
                              controller: bloc.usernameController,
                              label: context.l10n.accsFormUsernameLabel,
                              hint: context.l10n.accsFormUsernameHint,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              enabled: !readonly,
                              position: .middle,
                              inputFormatters: LoginItemFormFormatters.username,
                              autofillHints: const [AutofillHints.username],
                            ),

                            LoginItemFormTextField(
                              controller: bloc.passwordController,
                              label: context.l10n.accsFormPasswordLabel,
                              hint: context.l10n.accsFormPasswordHint,
                              obscurable: true,
                              textInputAction: TextInputAction.next,
                              enabled: !readonly,
                              position: .last,
                              inputFormatters: LoginItemFormFormatters.password,
                              autofillHints: const [AutofillHints.password],
                              trailing: readonly
                                  ? null
                                  : LoginItemFormGenPassIcon(
                                      onTap: () => bloc.add(
                                        const LoginItemFormEvent.willGenPassAppear(),
                                      ),
                                    ),
                              bottom: ValueListenableBuilder(
                                valueListenable: bloc.passwordController,
                                builder: (context, value, child) {
                                  return PasswordStrengthIndicator(
                                    password: value.text,
                                  );
                                },
                              ),
                            ),

                            BlocSelector<
                              LoginItemFormBloc,
                              LoginItemFormState,
                              bool
                            >(
                              selector: (state) =>
                                  state is DidGenPassAppearState,
                              builder: (context, isOpen) {
                                return AnimatedSwitcher(
                                  duration: AppDurations.medium,
                                  child: isOpen
                                      ? Padding(
                                          key: const ValueKey('genPassPanel'),
                                          padding: const EdgeInsets.only(
                                            left: Sizes.indent,
                                            right: Sizes.indent,
                                            top: Sizes.indent2x,
                                          ),
                                          child: LoginItemFormGenPassPanel(
                                            passwordController:
                                                bloc.passwordController,
                                          ),
                                        )
                                      : const SizedBox.shrink(
                                          key: ValueKey('genPassPanelHidden'),
                                        ),
                                );
                              },
                            ),
                            const SizedBox(height: Sizes.indent2x),
                            LoginItemFormTextField(
                              controller: bloc.notesController,
                              label: context.l10n.accsFormNotesLabel,
                              hint: context.l10n.accsFormNotesHint,
                              minLines: 3,
                              maxLines: 6,
                              textInputAction: TextInputAction.newline,
                              enabled: !readonly,
                              position: .single,
                              inputFormatters: LoginItemFormFormatters.notes,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

final class _MoreButton extends StatelessWidget with DialogHelper {
  final LoginItemFormScreenCoordinator coordinator;
  final LoginItem item;

  const _MoreButton({required this.coordinator, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final commonL10n = context.commonL10n;

    return CommonPopupMenuButton(
      size: const Size(40, 40),
      icon: Center(
        child: Icon(
          Icons.more_horiz_rounded,
          size: Sizes.iconMedium,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      onSelected: (p0) async {
        p0.payload?.call();
      },
      offset: const Offset(0.0, 40.0),
      items: [
        CommonPopupMenuItem(
          title: _MenuItem(
            title: l10n.accsFormMoreMenuCopy,
            icon: Icons.copy_outlined,
          ),
          payload: () => _onCopy(context),
        ),
        CommonPopupMenuItem(
          title: _MenuItem(
            title: l10n.notePreviewMoreMenuInfo,
            icon: Icons.info_outline,
          ),
          payload: () => _onInfo(context),
        ),
        CommonPopupMenuItem(
          title: _MenuItem(
            title: l10n.accsFormMoreMenuShare,
            icon: Icons.upload_outlined,
          ),
          payload: () => _onShare(context),
        ),
        CommonPopupMenuItem(
          title: _MenuItem(
            title: commonL10n.commonDelete,
            icon: Icons.delete_outline,
            color: theme.colorScheme.error,
          ),
          payload: () => _onDelete(context),
        ),
      ],
    );
  }

  Future<void> _onCopy(BuildContext context) async {
    final l10n = context.l10n;
    final lines = [
      if (item.title.trim().isNotEmpty)
        '${l10n.accsFormTitleLabel}: ${item.title.trim()}',
      if (item.websiteUrl.trim().isNotEmpty)
        '${l10n.accsFormWebsiteLabel}: ${item.websiteUrl.trim()}',
      if (item.username.trim().isNotEmpty)
        '${l10n.accsFormUsernameLabel}: ${item.username.trim()}',
      if (item.password.isNotEmpty)
        '${l10n.accsFormPasswordLabel}: ${item.password}',
      if (item.notes.trim().isNotEmpty)
        '${l10n.accsFormNotesLabel}: ${item.notes.trim()}',
    ];
    if (lines.isEmpty) return;

    // Goes through ClipboardHelper (not a raw Clipboard.setData) since this
    // block includes the password — same auto-clear-after-60s handling as
    // every other password copy in this screen.
    await ClipboardHelper.instance.setData(lines.join('\n'));

    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.commonL10n.commonCopied)));
  }

  void _onInfo(BuildContext context) {
    coordinator.onRawEventRoute(context, eventId: item.eventId);
  }

  void _onShare(BuildContext context) {
    context.read<LoginItemFormBloc>().add(
      const LoginItemFormEvent.willExport(),
    );
  }

  Future<void> _onDelete(BuildContext context) async {
    final commonL10n = context.commonL10n;
    final confirmed = await showConfirmation(
      context,
      isDestructive: true,
      title: commonL10n.commonAttention,
      message: context.l10n.accsConfirmationDialogDeletion,
    );
    if (confirmed != true || !context.mounted) return;

    context.read<LoginItemFormBloc>().add(const LoginItemFormEvent.delete());
  }
}

final class _MenuItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? color;

  const _MenuItem({required this.title, required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Sizes.indentVariant2x),
      child: Row(
        spacing: Sizes.indent,
        children: [
          Icon(icon, size: Sizes.iconSmall, color: color),
          Text(title, style: TextStyle(color: color)),
        ],
      ),
    );
  }
}

final class _TrailingAppbarButton extends StatelessWidget {
  const _TrailingAppbarButton();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginItemFormBloc, LoginItemFormState>(
      builder: (context, state) {
        final showSave = !state.data.readonly && state.data.canSave;
        return AnimatedSwitcher(
          duration: AppDurations.medium,
          child: showSave ? const _SaveButton() : const _ToggleModeButton(),
        );
      },
    );
  }
}

final class _SaveButton extends StatelessWidget {
  const _SaveButton();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<LoginItemFormBloc, LoginItemFormState, bool>(
      selector: (state) => state.data.canSave && state is! LoadingState,
      builder: (context, canSave) {
        return CupertinoButton(
          minimumSize: Size.zero,
          padding: const EdgeInsets.only(
            left: Sizes.indent2x,
            right: Sizes.indent,
            top: Sizes.indent,
            bottom: Sizes.indent,
          ),
          onPressed: canSave ? () => _onSave(context) : null,
          child: Text(context.commonL10n.commonButtonSave),
        );
      },
    );
  }

  void _onSave(BuildContext context) {
    FocusScope.of(context).unfocus();
    context.read<LoginItemFormBloc>().add(const LoginItemFormEvent.save());
  }
}

final class _ToggleModeButton extends StatelessWidget {
  const _ToggleModeButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginItemFormBloc, LoginItemFormState>(
      builder: (context, state) {
        final text = state.data.readonly
            ? context.l10n.accsFormEditButton
            : context.l10n.accsFormDoneButton;
        final isActive = state.data.readonly || !state.data.canSave;

        return CupertinoButton(
          minimumSize: Size.zero,
          padding: const EdgeInsets.only(
            left: Sizes.indent2x,
            right: Sizes.indent,
            top: Sizes.indent,
            bottom: Sizes.indent,
          ),
          onPressed: isActive ? () => _onTap(context) : null,
          child: Text(text),
        );
      },
    );
  }

  void _onTap(BuildContext context) {
    FocusScope.of(context).unfocus();
    context.read<LoginItemFormBloc>().add(
      const LoginItemFormEvent.toggleMode(),
    );
  }
}
