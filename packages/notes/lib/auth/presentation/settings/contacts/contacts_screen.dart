import 'package:common/app/theme/sizes.dart';
import 'package:common/presentation/widgets/settings_item_tile.dart';
import 'package:flutter/material.dart';
import 'package:common/presentation/markdown/markdown_screen.dart';
import 'package:nostr_notes/l10n/localization.dart';

final class ContactsScreen extends StatelessWidget {
  final bool showAppBarLeading;
  const ContactsScreen({super.key, required this.showAppBarLeading});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsItemContacts),

        leading: showAppBarLeading ? null : const SizedBox(),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Sizes.zero),
        child: Align(
          alignment: Alignment.topCenter,
          child: ListView(
            children: [
              RawSettingsItemTile(
                title: MarkdownScreenContent(
                  padding: const EdgeInsets.all(Sizes.indent2x),
                  content: l10n.settingsItemContactsContactsMd,
                ),
                sectionTitle: '',
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
