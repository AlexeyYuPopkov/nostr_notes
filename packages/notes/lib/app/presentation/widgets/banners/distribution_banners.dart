import 'package:common/app/theme/sizes.dart';
import 'package:common/presentation/buttons/prymary_button.dart';
import 'package:common/presentation/tools/link_tap_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nostr_notes/app/app_config.dart';
import 'package:nostr_notes/app/router/app_route/route_handler.dart';
import 'package:nostr_notes/auth/presentation/settings/settings/settings_screen_routes.dart';
import 'package:nostr_notes/l10n/localization.dart';

final class DistributionBanners extends StatelessWidget with LinkTapHandler {
  const DistributionBanners({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return const SizedBox.shrink();
    }

    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.only(
        top: Sizes.indent4x,
        bottom: Sizes.indent2x,
        left: Sizes.indent4x,
        right: Sizes.indent4x,
      ),
      child: Center(
        child: IntrinsicWidth(
          child: Row(
            mainAxisSize: .min,
            mainAxisAlignment: .center,
            spacing: Sizes.indent2x,
            children: [
              Flexible(
                child: _Banner(
                  buttonText: l10n.appStoreBannerButton,
                  icon: Icons.apple,
                  onTap: () => _launchAppStore(context),
                ),
              ),
              Flexible(
                child: _Banner(
                  buttonText: l10n.apkBannerButton,
                  icon: Icons.android,
                  onTap: () => _launchApk(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _launchAppStore(BuildContext context) =>
      launchUrl(context, url: AppConfig.appStoreLink);

  void _launchApk(BuildContext context) =>
      RouteHandler.of(context)?.onRoute(const ApkDistributionRoute(), context);
}

final class _Banner extends StatelessWidget {
  final String buttonText;
  final IconData icon;
  final VoidCallback onTap;

  const _Banner({
    required this.buttonText,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return OpacityOutlinedButton(
      onTap: onTap,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: colorScheme.onSurface, size: Sizes.iconMedium),
          const SizedBox(width: Sizes.indent),
          Flexible(
            child: Text(
              buttonText,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
