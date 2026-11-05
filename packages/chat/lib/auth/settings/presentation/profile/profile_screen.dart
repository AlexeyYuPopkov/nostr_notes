import 'dart:async';

import 'package:chat/auth/settings/domain/models/profile_exception.dart';
import 'package:chat/auth/settings/presentation/profile/provider/profile_data.dart';
import 'package:chat/auth/settings/presentation/profile/provider/profile_provider.dart';
import 'package:chat/auth/settings/presentation/profile/provider/profile_state.dart';
import 'package:chat/auth/settings/presentation/profile/widgets/copyable_key_field.dart';
import 'package:chat/l10n/localization.dart';
import 'package:common/app/theme/sizes.dart';
import 'package:common/presentation/account_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class ProfileScreen extends ConsumerWidget {
  static const nameFieldSemanticsId = 'ProfileScreen.nameField';
  static const displayNameFieldSemanticsId = 'ProfileScreen.displayNameField';
  static const pictureFieldSemanticsId = 'ProfileScreen.pictureField';
  static const saveButtonSemanticsId = 'ProfileScreen.saveButton';
  static const npubCopyButtonSemanticsId = 'ProfileScreen.npubCopyButton';
  static const pubkeyCopyButtonSemanticsId = 'ProfileScreen.pubkeyCopyButton';

  static const _avatarSize = 96.0;

  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(profileProviderProvider, (_, state) => _notify(context, state));
    final state = ref.watch(profileProviderProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.profileTitle),
        actions: [_SaveButton(state: state)],
      ),
      body: switch (state) {
        ProfileLoading() => const Center(
          child: CircularProgressIndicator.adaptive(),
        ),
        _ => SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(Sizes.indent2x),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              Center(
                child: AccountAvatar(
                  pubkey: state.data.profile.pubkey,
                  size: _avatarSize,
                  pictureUrl: state.data.previewPictureUrl,
                ),
              ),
              const SizedBox(height: Sizes.indent2x),
              _ProfileForm(
                key: ValueKey(state.data.formRevision),
                data: state.data,
                isEnabled: state is! ProfileSaving,
              ),
              const SizedBox(height: Sizes.indent4x),
              CopyableKeyField(
                label: context.l10n.profileNpubLabel,
                value: state.data.npub,
                copyButtonSemanticsId: npubCopyButtonSemanticsId,
              ),
              const SizedBox(height: Sizes.indent2x),
              CopyableKeyField(
                label: context.l10n.profilePubkeyLabel,
                value: state.data.pubkey,
                copyButtonSemanticsId: pubkeyCopyButtonSemanticsId,
              ),
            ],
          ),
        ),
      },
    );
  }

  static void _notify(BuildContext context, ProfileState state) {
    final message = switch (state) {
      ProfileSaved() => context.l10n.profileSaved,
      ProfileError(error: ProfileNotPublishedException()) =>
        context.l10n.profileNotPublished,
      ProfileError() => context.l10n.profileSaveError,
      _ => null,
    };
    if (message != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}

final class _SaveButton extends ConsumerWidget {
  final ProfileState state;

  const _SaveButton({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.read(profileProviderProvider.notifier);
    final isSaving = state is ProfileSaving;
    final canSave = state is! ProfileLoading && !isSaving && state.data.canSave;

    return Semantics(
      identifier: ProfileScreen.saveButtonSemanticsId,
      child: TextButton(
        onPressed: canSave ? () => unawaited(provider.save()) : null,
        child: isSaving
            ? const SizedBox.square(
                dimension: Sizes.iconMedium,
                child: CircularProgressIndicator.adaptive(),
              )
            : Text(context.l10n.profileSave),
      ),
    );
  }
}

final class _ProfileForm extends ConsumerWidget {
  final ProfileData data;
  final bool isEnabled;

  const _ProfileForm({super.key, required this.data, required this.isEnabled});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.read(profileProviderProvider.notifier);
    final l10n = context.l10n;

    return Column(
      children: [
        _ProfileTextField(
          semanticsId: ProfileScreen.nameFieldSemanticsId,
          initialValue: data.draft.name,
          label: l10n.profileNameLabel,
          helper: l10n.profileNameHelper,
          isEnabled: isEnabled,
          onChanged: provider.onNameChanged,
        ),
        const SizedBox(height: Sizes.indent2x),
        _ProfileTextField(
          semanticsId: ProfileScreen.displayNameFieldSemanticsId,
          initialValue: data.draft.displayName,
          label: l10n.profileDisplayNameLabel,
          helper: l10n.profileDisplayNameHelper,
          isEnabled: isEnabled,
          onChanged: provider.onDisplayNameChanged,
        ),
        const SizedBox(height: Sizes.indent2x),
        _ProfileTextField(
          semanticsId: ProfileScreen.pictureFieldSemanticsId,
          initialValue: data.draft.picture,
          label: l10n.profilePictureLabel,
          hint: l10n.profilePictureHint,
          error: data.isPictureValid ? null : l10n.profilePictureInvalid,
          keyboardType: TextInputType.url,
          isEnabled: isEnabled,
          onChanged: provider.onPictureChanged,
        ),
      ],
    );
  }
}

final class _ProfileTextField extends StatelessWidget {
  final String semanticsId;
  final String initialValue;
  final String label;
  final String? helper;
  final String? hint;
  final String? error;
  final TextInputType? keyboardType;
  final bool isEnabled;
  final ValueChanged<String> onChanged;

  const _ProfileTextField({
    required this.semanticsId,
    required this.initialValue,
    required this.label,
    this.helper,
    this.hint,
    this.error,
    this.keyboardType,
    required this.isEnabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      identifier: semanticsId,
      child: TextFormField(
        initialValue: initialValue,
        enabled: isEnabled,
        keyboardType: keyboardType,
        autocorrect: false,
        decoration: InputDecoration(
          labelText: label,
          helperText: helper,
          helperMaxLines: 2,
          hintText: hint,
          errorText: error,
        ),
        onChanged: onChanged,
      ),
    );
  }
}
