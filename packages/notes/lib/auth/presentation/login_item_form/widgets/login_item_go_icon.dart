import 'package:common/app/theme/sizes.dart';
import 'package:common/presentation/widgets/progress_hud/progress_hud.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nostr_notes/auth/presentation/tools/clipboard_helper.dart';
import 'package:nostr_notes/l10n/localization.dart';
import 'package:url_launcher/url_launcher.dart';

final class LoginItemGoIcon extends StatefulWidget {
  static const double size = Sizes.iconMedium;

  final String url;
  final String username;
  final String password;

  const LoginItemGoIcon({
    super.key,
    required this.url,
    required this.username,
    required this.password,
  });

  @override
  State<LoginItemGoIcon> createState() => _LoginItemGoIconState();
}

final class _LoginItemGoIconState extends State<LoginItemGoIcon>
    with WidgetsBindingObserver {
  static const _hudDisplayDuration = Duration(seconds: 2);

  /// Sign-in forms ask for the username first, so that is what opening the
  /// site puts on the clipboard. The password follows once the user comes
  /// back here — see [_handOffPassword] — which is the moment they need it.
  /// Long enough for a normal sign-in, short enough that a password is not
  /// left staged after the user has moved on.
  static const _handoffWindow = Duration(minutes: 3);

  Uri? _launchableUri;
  String? _stagedUsername;
  DateTime? _handoffExpiry;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkCanOpen();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _handOffPassword();
  }

  @override
  void didUpdateWidget(covariant LoginItemGoIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) _checkCanOpen();
  }

  Future<void> _checkCanOpen() async {
    final urlStr = widget.url.trim();

    if (urlStr.isEmpty) {
      if (!mounted) return;
      setState(() => _launchableUri = null);
      return;
    }

    final uri = Uri.tryParse(urlStr);
    final canOpen = uri != null && await canLaunchUrl(uri);
    if (!mounted) return;
    setState(() => _launchableUri = canOpen ? uri : null);
  }

  Future<void> _onTap(BuildContext context) async {
    final uri = _launchableUri;
    if (uri == null) return;

    final username = widget.username.trim();
    final password = widget.password;

    // Falls back to the password when there is no username to lead with,
    // which is the whole point of the button on such an item.
    final copied = username.isNotEmpty ? username : password;
    if (copied.isNotEmpty) {
      await ClipboardHelper.instance.setData(copied);
    }

    final stagePassword =
        username.isNotEmpty && password.isNotEmpty && password != username;
    _stagedUsername = stagePassword ? username : null;
    _handoffExpiry = stagePassword ? DateTime.now().add(_handoffWindow) : null;

    if (!context.mounted) return;
    await _showHud(
      context,
      username.isNotEmpty ? _CopiedField.username : _CopiedField.password,
    );

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  /// Swaps the staged username for the password when the user returns from
  /// the browser, so the second half of a sign-in costs no taps.
  Future<void> _handOffPassword() async {
    final username = _stagedUsername;
    final expiry = _handoffExpiry;
    if (username == null || expiry == null) return;

    if (DateTime.now().isAfter(expiry)) {
      _clearHandoff();
      return;
    }
    // Anything the user copied while away wins; theirs is not ours to drop.
    if (!await ClipboardHelper.instance.holds(username)) {
      _clearHandoff();
      return;
    }

    await ClipboardHelper.instance.setData(widget.password);
    _clearHandoff();

    if (!mounted) return;
    await _showHud(context, _CopiedField.password);
  }

  void _clearHandoff() {
    _stagedUsername = null;
    _handoffExpiry = null;
  }

  Future<void> _showHud(BuildContext context, _CopiedField field) async {
    final hud = ProgressHud.of(context);
    hud?.setLoading(isLoading: true, policy: _HudPolicy(field: field));

    await Future.delayed(_hudDisplayDuration);

    if (!context.mounted) return;
    hud?.setLoading(isLoading: false);
  }

  @override
  Widget build(BuildContext context) {
    return ProgressHudWidgetContent(
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final enabled = _launchableUri != null;

          return CupertinoButton(
            minimumSize: Size.zero,
            padding: EdgeInsets.zero,
            onPressed: enabled ? () => _onTap(context) : null,
            child: Icon(
              Icons.open_in_new,
              color: enabled
                  ? theme.colorScheme.onSurfaceVariant
                  : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              size: LoginItemGoIcon.size,
            ),
          );
        },
      ),
    );
  }
}

/// Which credential the confirmation is about. A password manager that says
/// only "copied" leaves the user guessing what is in the clipboard.
enum _CopiedField {
  username,
  password;

  String label(BuildContext context) => switch (this) {
    _CopiedField.username => context.l10n.accsFormGoUsernameCopiedMessage,
    _CopiedField.password => context.l10n.accsFormGoButtonCopiedMessage,
  };
}

final class _HudPolicy extends HudPolicy {
  /// A floor, not a fixed size: the box keeps its square look for short
  /// labels and grows for translations that need more room. Cyrillic runs
  /// well past the English wording, and a hard square clipped it.
  static const _minSize = 132.0;
  static const _maxWidth = 240.0;

  final _CopiedField field;

  const _HudPolicy({required this.field});

  @override
  Widget build(BuildContext context, ProgressHudVm vm) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hint = field.label(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Sizes.indent2x),
        child: RepaintBoundary(
          child: Material(
            color: theme.colorScheme.tertiaryContainer,
            elevation: Sizes.thickness * 4,
            borderRadius: BorderRadius.circular(Sizes.radiusVariant),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: _minSize,
                minHeight: _minSize,
                maxWidth: _maxWidth,
              ),
              child: Padding(
                padding: const EdgeInsets.all(Sizes.indent2x),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  spacing: Sizes.indent2x,
                  children: [
                    SizedBox.square(
                      dimension: Sizes.icon,
                      child: CircularProgressIndicator.adaptive(
                        strokeWidth: Sizes.thickness * 2,
                        value: vm.progress,
                      ),
                    ),
                    Text(
                      hint,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
