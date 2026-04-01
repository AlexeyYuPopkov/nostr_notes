import 'package:flutter/material.dart';
import 'package:nostr_notes/app/router/screens_assembly/screens_assembly.dart';
import 'package:nostr_notes/auth/presentation/edit_note_markdown_screen/edit_note_markdown_screen.dart';

import 'package:nostr_notes/auth/presentation/model/path_params.dart';
import 'package:nostr_notes/auth/presentation/note_preview_screen/note_preview_screen.dart';
import 'package:nostr_notes/auth/presentation/settings/contacts/contacts_screen.dart';
import 'package:nostr_notes/auth/presentation/settings/del_acc/del_acc_screen.dart';
import 'package:nostr_notes/auth/presentation/settings/help_screen/help_screen.dart';
import 'package:nostr_notes/auth/presentation/settings/preferences/preferences_screen.dart';
import 'package:nostr_notes/auth/presentation/settings/privacy_policy_screen/privacy_policy_screen.dart';
import 'package:nostr_notes/auth/presentation/settings/relays_list/relays_list_screen.dart';

final class AppScreensAssembly implements ScreensAssembly {
  const AppScreensAssembly();

  @override
  Widget createNotePreview(PathParams pathParams) {
    return NotePreviewScreen(pathParams: pathParams);
  }

  @override
  Widget createEditNoteMarkdownScreen(PathParams? pathParams) {
    return EditMarkdownNoteScreen(pathParams: pathParams);
  }

  @override
  Widget createAppSettingsScreen() => PreferencesScreen();

  @override
  Widget createRelaysListScreen() => const RelaysListScreen();

  @override
  Widget createHelpScreen() => const HelpScreen();

  @override
  Widget createContactsScreen({bool showAppBarLeading = true}) =>
      ContactsScreen(showAppBarLeading: showAppBarLeading);

  @override
  Widget createPrivacyPolicyScreen() => const PrivacyPolicyScreen();

  @override
  Widget deleteAccUsecaseScreen() => const DelAccScreen();
}
