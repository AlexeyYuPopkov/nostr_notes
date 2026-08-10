import 'package:common/app/theme/sizes.dart';
import 'package:common/l10n/localization.dart';
import 'package:common/presentation/dialogs/dialog_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/auth/presentation/login_item_form/widgets/login_item_go_icon.dart';
import 'package:nostr_notes/l10n/localization.dart';

import 'bloc/login_item_details_params.dart';
import 'bloc/login_item_form_bloc.dart';
import 'bloc/login_item_form_event.dart';
import 'bloc/login_item_form_state.dart';
import 'tools/login_item_form_formatters.dart';
import 'widgets/login_item_form_header.dart';
import 'widgets/login_item_form_text_field.dart';

final class LoginItemFormScreen extends StatelessWidget with DialogHelper {
  final LoginItemDetailsParams params;

  const LoginItemFormScreen({super.key, required this.params});

  void _listener(BuildContext context, LoginItemFormState state) {
    switch (state) {
      case CommonState():
      case LoadingState():
        break;
      case ErrorState():
        showError(context, error: state.e);
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginItemFormBloc(pathParams: params),
      child: BlocConsumer<LoginItemFormBloc, LoginItemFormState>(
        listener: _listener,
        builder: (context, state) {
          final bloc = context.read<LoginItemFormBloc>();
          final isLoading = state is LoadingState;
          final readonly = state.data.readonly;

          // return AccsIconsPreviewScreen();

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
                      if (state.data.isEditing) const _DeleteButton(),
                      const _TrailingAppbarButton(),
                      const SizedBox(width: Sizes.indent2x),
                    ],
                  ),
                  SliverSafeArea(
                    top: false,
                    sliver: SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        Sizes.indent,
                        Sizes.indent4x,
                        Sizes.indent,
                        Sizes.indent2x,
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
    );
  }
}

final class _DeleteButton extends StatelessWidget with DialogHelper {
  const _DeleteButton();

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      minimumSize: Size.zero,
      padding: const EdgeInsets.only(left: Sizes.indent, right: Sizes.indent),
      onPressed: () => _onTap(context),
      child: Icon(
        Icons.delete_outline,
        color: Theme.of(context).colorScheme.error,
      ),
    );
  }

  Future<void> _onTap(BuildContext context) async {
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
