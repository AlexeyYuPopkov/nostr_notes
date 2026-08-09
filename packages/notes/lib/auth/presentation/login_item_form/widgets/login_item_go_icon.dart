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
  final String password;

  const LoginItemGoIcon({super.key, required this.url, required this.password});

  @override
  State<LoginItemGoIcon> createState() => _LoginItemGoIconState();
}

final class _LoginItemGoIconState extends State<LoginItemGoIcon> {
  static const _hudDisplayDuration = Duration(seconds: 2);

  Uri? _launchableUri;

  @override
  void initState() {
    super.initState();
    _checkCanOpen();
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

    if (widget.password.isNotEmpty) {
      await ClipboardHelper.instance.setData(widget.password);
    }

    if (!context.mounted) return;
    final hud = ProgressHud.of(context);
    hud?.setLoading(isLoading: true, policy: const _HudPolicy());

    await Future.delayed(_hudDisplayDuration);

    if (!context.mounted) return;
    hud?.setLoading(isLoading: false);

    await launchUrl(uri, mode: LaunchMode.externalApplication);
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

final class _HudPolicy extends HudPolicy {
  static const _size = 132.0;

  const _HudPolicy();

  @override
  Widget build(BuildContext context, ProgressHudVm vm) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hint = context.l10n.accsFormGoButtonCopiedMessage;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Sizes.indent2x),
        child: RepaintBoundary(
          child: Material(
            color: theme.colorScheme.tertiaryContainer,
            elevation: Sizes.thickness * 4,
            borderRadius: BorderRadius.circular(Sizes.radiusVariant),
            child: SizedBox.square(
              dimension: _size,
              child: Padding(
                padding: const EdgeInsets.all(Sizes.indent2x),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
