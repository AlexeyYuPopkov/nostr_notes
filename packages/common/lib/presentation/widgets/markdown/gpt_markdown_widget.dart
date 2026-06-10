import 'package:common/app/theme/gpt_markdown_theme_data.dart';
import 'package:common/app/theme/sizes.dart';
import 'package:common/l10n/localization.dart';
import 'package:common/presentation/tools/link_tap_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gpt_markdown/custom_widgets/markdown_config.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:nostr_notes/common/presentation/layout/app_platform.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

class GptMarkdownWidget extends StatefulWidget {
  final String md;
  final CodeBlockBuilder? codeBuilder;
  final OrderedListBuilder? orderedListBuilder;
  final HighlightBuilder? highlightBuilder;

  const GptMarkdownWidget({
    super.key,
    required this.md,
    this.codeBuilder,
    this.orderedListBuilder,
    this.highlightBuilder,
  });

  @override
  State<GptMarkdownWidget> createState() => _GptMarkdownWidgetState();
}

class _GptMarkdownWidgetState extends State<GptMarkdownWidget> {
  Offset _tapPosition = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final mdTheme = Theme.of(context).extension<AppGptMarkdownTheme>()!;
    return Listener(
      onPointerDown: (event) => _tapPosition = event.position,
      child: GptMarkdownTheme(
        gptThemeData: mdTheme.data,
        child: GptMarkdown(
          widget.md,
          style: const TextStyle(fontSize: TextSizes.normal),
          codeBuilder: widget.codeBuilder,
          highlightBuilder: widget.highlightBuilder,
          orderedListBuilder: widget.orderedListBuilder,
          onLinkTap: (url, title) => _onLinkTap(url),
        ),
      ),
    );
  }

  Future<void> _onLinkTap(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;

    bool canOpen = false;
    try {
      canOpen = await launcher.canLaunchUrl(uri);
    } catch (_) {}

    if (!mounted) {
      return;
    }

    if (!canOpen) {
      await _copyToClipboard(url);
      return;
    }

    final theme = Theme.of(context);
    final l10n = context.commonL10n;
    final screenSize = MediaQuery.sizeOf(context);
    final position = RelativeRect.fromLTRB(
      Sizes.padding2x,
      Sizes.padding2x + _tapPosition.dy,
      screenSize.width - _tapPosition.dx,
      screenSize.height - _tapPosition.dy,
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

    if (!mounted) {
      return;
    }

    switch (result) {
      case _LinkMenuAction.copyLink:
        await _copyToClipboard(url);
      case _LinkMenuAction.openInBrowser:
        await launcher.launchUrl(uri);
      case _LinkMenuAction.openInExternalBrowser:
        await launcher.launchUrl(
          uri,
          mode: launcher.LaunchMode.externalApplication,
        );
      case null:
        break;
    }
  }

  PopupMenuItem<_LinkMenuAction> _menuItem(
    _LinkMenuAction value,
    IconData icon,
    String title,
  ) {
    return PopupMenuItem(
      value: value,
      height: 32,
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

  Future<void> _copyToClipboard(String url) async {
    if (mounted) {
      await copyUrlToClipboard(context, url);
    }
  }
}

enum _LinkMenuAction { copyLink, openInBrowser, openInExternalBrowser }
