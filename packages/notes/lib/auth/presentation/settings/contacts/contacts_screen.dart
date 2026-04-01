import 'package:flutter/material.dart';
import 'package:nostr_notes/l10n/localization.dart';
import 'package:nostr_notes/common/presentation/markdown_screen.dart';

final class ContactsScreen extends StatelessWidget {
  final bool showAppBarLeading;
  const ContactsScreen({super.key, required this.showAppBarLeading});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.helpScreenTitle),
        leading: showAppBarLeading ? null : const SizedBox(),
      ),
      body: Center(
        child: MarkdownScreenContent(
          content: l10n.settingsItemContactsContentMd,
        ),
      ),
    );
  }
}
