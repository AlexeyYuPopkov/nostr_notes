import 'package:common/app/theme/sizes.dart';
import 'package:common/presentation/widgets/settings_item_tile.dart';
import 'package:flutter/material.dart';
import 'package:common/presentation/widgets/markdown/gpt_markdown_widget.dart';
import 'package:nostr_notes/app/app_config.dart';
import 'package:nostr_notes/common/presentation/layout/layout_config.dart';
import 'package:nostr_notes/l10n/app_localizations.dart';
import 'package:nostr_notes/l10n/localization.dart';

final class ApkDistributionScreen extends StatelessWidget {
  static const apkUrl = AppConfig.apkGHPagesUrl;
  static const sha256Url = AppConfig.apkGHPagesSha256Url;
  final bool showAppBar;
  const ApkDistributionScreen({super.key, this.showAppBar = true});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: showAppBar
          ? AppBar(title: Text(l10n.apkDistributionTitle))
          : null,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: LayoutConfig.desktopScreenWidth,
          ),
          child: ListView(
            children: [
              RawSettingsItemTile(
                title: Padding(
                  padding: const EdgeInsets.all(Sizes.indent2x),
                  child: GptMarkdownWidget(md: _getContent(context.l10n)),
                ),
                sectionTitle: 'Android APK',
                position: .single,
                onTap: null,
              ),
              RawSettingsItemTile(
                title: Padding(
                  padding: const EdgeInsets.all(Sizes.indent2x),
                  child: GptMarkdownWidget(
                    md: '[${l10n.apkDistributionViewChecksum}]($sha256Url)',
                  ),
                ),
                sectionTitle: 'SHA-256 Checksum',
                position: .single,
                onTap: null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getContent(AppLocalizations l10n) {
    return '''
      ${l10n.apkDistributionDescription}\n[${l10n.apkDistributionDownloadButton}]($apkUrl)
    ''';
  }
}
