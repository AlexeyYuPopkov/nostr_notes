import 'dart:async';

import 'package:common/app/theme/sizes.dart';
import 'package:common/l10n/localization.dart';
import 'package:common/presentation/tools/link_tap_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nostr_notes/common/presentation/layout/app_platform.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

mixin OnTapLinkHelper {
  Future<void> onLinkTap(
    BuildContext context, {
    required String url,
    required Offset tapPosition,
    FutureOr<void> Function(String)? onCopy,
  }) async {
    final urlStr = url.trim();
    final uri = Uri.tryParse(urlStr);
    if (uri == null) {
      return;
    }

    bool canOpen = false;
    try {
      canOpen = await launcher.canLaunchUrl(uri);
    } catch (_) {}

    if (!context.mounted) {
      return;
    }

    if (!canOpen) {
      if (onCopy != null) {
        await onCopy(url);
      } else {
        await _onCopy(context, url);
      }

      return;
    }

    final theme = Theme.of(context);
    final l10n = context.commonL10n;
    final screenSize = MediaQuery.sizeOf(context);
    final position = RelativeRect.fromLTRB(
      Sizes.padding2x,
      Sizes.padding2x + tapPosition.dy,
      screenSize.width - tapPosition.dx,
      screenSize.height - tapPosition.dy,
    );

    final result = await showMenu<_LinkMenuAction>(
      context: context,
      color: theme.colorScheme.surface.withValues(alpha: 0.90),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(Sizes.radiusVariant)),
      ),
      shadowColor: theme.colorScheme.onSurface.withValues(alpha: 0.3),
      position: position,
      items: [
        _menuItem(
          _LinkMenuAction.copyLink,
          Icons.link,
          l10n.commonLinkCopyLink,
        ),
        if (kIsWeb)
          _menuItem(
            _LinkMenuAction.openInBrowser,
            Icons.open_in_new,
            l10n.commonLinkOpenInNewTab,
          )
        else ...[
          _menuItem(
            _LinkMenuAction.openInBrowser,
            Icons.open_in_browser_outlined,
            l10n.commonLinkOpenInBrowser,
          ),
          if (const AppPlatform().isMobile)
            _menuItem(
              _LinkMenuAction.openInExternalBrowser,
              Icons.open_in_new,
              l10n.commonLinkOpenInExternalBrowser,
            ),
        ],
      ],
    );

    if (!context.mounted) {
      return;
    }

    switch (result) {
      case _LinkMenuAction.copyLink:
        if (onCopy != null) {
          await onCopy(url);
        } else {
          await _onCopy(context, url);
        }
        break;
      case _LinkMenuAction.openInBrowser:
        await launcher.launchUrl(uri);
        break;
      case _LinkMenuAction.openInExternalBrowser:
        await launcher.launchUrl(
          uri,
          mode: launcher.LaunchMode.externalApplication,
        );
        break;
      case null:
        break;
    }
  }

  Future<void> _onCopy(BuildContext context, String str) async {
    if (context.mounted) {
      await copyUrlToClipboard(context, str);
    }
  }

  PopupMenuItem<_LinkMenuAction> _menuItem(
    _LinkMenuAction value,
    IconData icon,
    String title,
  ) {
    return PopupMenuItem(
      value: value,
      height: 44.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Sizes.indent),
        child: Row(
          spacing: Sizes.indent,
          children: [
            Icon(icon, size: Sizes.iconSmall),
            Text(title),
          ],
        ),
      ),
    );
  }
}

Future<void> copyUrlToClipboard(BuildContext context, String url) async {
  final text = LinkTapHandler.sanitizeUrl(url);
  await Clipboard.setData(ClipboardData(text: text));
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          children: [Text('${context.commonL10n.commonCopied}:'), Text(text)],
        ),
      ),
    );
  }
}

enum _LinkMenuAction { copyLink, openInBrowser, openInExternalBrowser }
