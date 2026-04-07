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
      body: Align(
        alignment: Alignment.topCenter,
        child: MarkdownScreenContent(
          content: l10n.settingsItemContactsContentMd,
        ),
      ),
    );
  }
}
