import 'package:flutter/material.dart';
import 'package:nostr_notes/app/l10n/localization.dart';
import 'package:nostr_notes/common/presentation/markdown_screen.dart';

final class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.helpScreenTitle)),
      body: MarkdownScreenContent(content: l10n.settingsItemContactsContentMd),
    );
  }
}
