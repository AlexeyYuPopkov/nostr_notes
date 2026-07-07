import 'package:common/app/theme/sizes.dart';
import 'package:common/presentation/widgets/settings_item_tile.dart';
import 'package:flutter/material.dart';
import 'package:common/presentation/widgets/markdown/gpt_markdown_widget.dart';
import 'package:nostr_notes/app/app_config.dart';
import 'package:nostr_notes/common/presentation/layout/layout_config.dart';
import 'package:nostr_notes/l10n/localization.dart';

final class ApkDistributionScreen extends StatelessWidget {
  static const _groupUrl = AppConfig.googleGroupsTestersUrl;
  static const _testingUrl = AppConfig.googlePlayTestingUrl;

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.apkDistributionSubtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: Sizes.indent2x),
                      GptMarkdownWidget.withCodeBuilders(
                        md: l10n.apkDistributionInstructions(
                          _groupUrl,
                          _testingUrl,
                        ),
                      ),
                    ],
                  ),
                ),
                sectionTitle: 'Google Play',
                position: .single,
                onTap: null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
