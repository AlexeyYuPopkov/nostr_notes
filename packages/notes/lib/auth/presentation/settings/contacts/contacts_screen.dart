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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Sizes.indent2x),
        child: Align(
          alignment: Alignment.topCenter,
          child: CustomScrollView(
            slivers: [
              SliverAppBar.medium(
                title: Text(l10n.settingsItemContacts),
                toolbarHeight: Sizes.appBarHeight,
                leading: showAppBarLeading ? null : const SizedBox(),
              ),

              //settingsItemContactsLabelContacts
              SliverToBoxAdapter(
                child: RawSettingsItemTile(
                  title: MarkdownScreenContent(
                    content: l10n.settingsItemContactsContactsMd,
                  ),
                  sectionTitle: '',
                  position: .single,
                  onTap: null,
                ),
              ),
              SliverToBoxAdapter(
                child: RawSettingsItemTile(
                  title: MarkdownScreenContent(
                    content: l10n.settingsItemContactsMdFaq,
                  ),
                  sectionTitle: l10n.settingsItemContactsLabelFAQ,
                  position: .single,
                  onTap: null,
                ),
              ),
              // SliverToBoxAdapter(
              //   child: MarkdownScreenContent(
              //     content: l10n.settingsItemContactsMdFaq,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
