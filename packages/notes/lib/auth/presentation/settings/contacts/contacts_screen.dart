import 'package:common/app/theme/sizes.dart';
import 'package:common/presentation/widgets/settings_item_tile.dart';
import 'package:flutter/material.dart';
import 'package:common/presentation/markdown/markdown_screen.dart';
import 'package:nostr_notes/common/presentation/layout/layout_config.dart';
import 'package:nostr_notes/l10n/localization.dart';

final class ContactsScreen extends StatelessWidget {
  final bool showAppBar;
  const ContactsScreen({super.key, required this.showAppBar});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: showAppBar
          ? AppBar(title: Text(l10n.settingsItemContacts))
          : null,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: LayoutConfig.desktopScreenWidth,
          ),
          child: ListView(
            children: [
              RawSettingsItemTile(
                title: MarkdownScreenContent(
                  padding: const EdgeInsets.all(Sizes.indent2x),
                  content: l10n.settingsItemContactsContactsMd,
                ),
                sectionTitle: showAppBar ? '' : l10n.settingsItemContacts,
                position: .single,
                onTap: null,
              ),
              RawSettingsItemTile(
                title: MarkdownScreenContent(
                  padding: const EdgeInsets.all(Sizes.indent2x),
                  content: l10n.settingsItemContactsMdFaq,
                ),
                sectionTitle: l10n.settingsItemContactsLabelFAQ,
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
