import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/app/l10n/localization.dart';
import 'package:nostr_notes/app/sizes.dart';
import 'package:nostr_notes/auth/presentation/settings/preferences/credentials_data_screen/bloc/credentials_data_bloc.dart';
import 'package:nostr_notes/auth/presentation/settings/preferences/credentials_data_screen/bloc/credentials_data_state.dart';
import 'package:nostr_notes/common/presentation/dialogs/dialog_helper.dart';
import 'package:nostr_notes/common/presentation/widgets/info_text.dart';

final class CredentialsDataScreen extends StatelessWidget with DialogHelper {
  const CredentialsDataScreen({super.key});

  void _listener(BuildContext context, CredentialsDataState state) {
    switch (state) {
      case CommonState():
        break;
      case LoadingState():
        break;
      case ErrorState():
        showError(context, error: state.error);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CredentialsDataBloc(),
      child: BlocConsumer<CredentialsDataBloc, CredentialsDataState>(
        listener: _listener,
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(context.l10n.credentialsDataScreenTitle),
            ),
            body: SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(Sizes.indent2x),
                children: [
                  _Item(
                    title: context.l10n.credentialsDataScreenLabelNsec,
                    value: state.data.nsec,
                  ),
                  InfoText(text: context.l10n.credentialsDataScreenWarningNsec),
                  _Item(
                    title: context.l10n.credentialsDataScreenLabelPrivateKey,
                    value: state.data.privateKey,
                  ),
                  InfoText(
                    text: context.l10n.credentialsDataScreenWarningPrivateKey,
                  ),
                  _Item(
                    title: context.l10n.credentialsDataScreenLabelPubKey,
                    value: state.data.pubkey,
                    secure: false,
                  ),
                  InfoText(text: context.l10n.credentialsDataScreenInfoPubKey),
                  _Item(
                    title: context.l10n.credentialsDataScreenLabelPin,
                    value: state.data.pin,
                  ),
                  InfoText(text: context.l10n.credentialsDataScreenWarningPin),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

final class _Item extends StatefulWidget {
  final String title;
  final String value;
  final bool secure;

  const _Item({required this.title, required this.value, this.secure = true});

  @override
  State<_Item> createState() => _ItemState();
}

class _ItemState extends State<_Item> {
  static const _visibilityDuration = Duration(seconds: 2);

  bool _obscured = true;
  bool _copied = false;
  Timer? _visibilityTimer;
  Timer? _copyTimer;

  bool get _isObscured => widget.secure && _obscured;

  @override
  void dispose() {
    _visibilityTimer?.cancel();
    _copyTimer?.cancel();
    super.dispose();
  }

  void _toggleVisibility() {
    _visibilityTimer?.cancel();
    setState(() => _obscured = false);
    _visibilityTimer = Timer(_visibilityDuration, () {
      if (mounted) setState(() => _obscured = true);
    });
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.value));
    _copyTimer?.cancel();
    setState(() => _copied = true);
    _copyTimer = Timer(_visibilityDuration, () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(
        left: Sizes.indent2x,
        right: Sizes.indent2x,
        bottom: Sizes.indent2x,
      ),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        children: [
          Text(
            widget.title,
            style: theme.textTheme.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: Sizes.halfIndent),
          TextFormField(
            key: ValueKey(widget.value),
            initialValue: widget.value,
            readOnly: true,
            maxLines: 1,
            obscureText: _isObscured,
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              border: const OutlineInputBorder(borderSide: .none),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.secure)
                    IconButton(
                      icon: Icon(
                        _isObscured ? Icons.visibility_off : Icons.visibility,
                        color: theme.colorScheme.primary,
                      ),
                      onPressed: _toggleVisibility,
                    ),
                  IconButton(
                    icon: Icon(
                      _copied ? Icons.check : Icons.copy,
                      color: theme.colorScheme.primary,
                    ),
                    onPressed: _copyToClipboard,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
