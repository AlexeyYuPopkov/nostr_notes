import 'package:common/presentation/raw_event/raw_event_screen.dart';
import 'package:nostr_notes/auth/presentation/settings/apk_distribution/apk_distribution_screen.dart';
import 'package:nostr_notes/auth/presentation/settings/contacts/contacts_screen.dart';
import 'package:flutter/material.dart';
import 'package:nostr_notes/app/router/screens_assembly/screens_assembly.dart';
import 'package:nostr_notes/auth/presentation/edit_note_markdown_screen/edit_note_markdown_screen.dart';

import 'package:nostr_notes/auth/presentation/model/path_params.dart';
import 'package:nostr_notes/auth/presentation/note_preview_screen/note_preview_screen.dart';
import 'package:nostr_notes/auth/presentation/settings/del_acc/del_acc_screen.dart';
import 'package:nostr_notes/auth/presentation/settings/donate_lightning/donate_lightning_screen.dart';
import 'package:nostr_notes/auth/presentation/settings/export_import/export_import_screen.dart';
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
  Widget createRawEventScreen(PathParamsEventId params) {
    return RawEventScreen(eventId: params.eventId);
  }

  @override
  Widget createEditNoteMarkdownScreen(PathParams? pathParams) {
    return EditMarkdownNoteScreen(pathParams: pathParams);
  }

  @override
  Widget createAppSettingsScreen() => const PreferencesScreen();

  @override
  Widget createRelaysListScreen() => const RelaysListScreen();

  @override
  Widget createHelpScreen() => const HelpScreen();

  @override
  Widget createContactsScreen({bool showAppBar = true}) =>
      ContactsScreen(showAppBar: showAppBar);

  @override
  Widget createPrivacyPolicyScreen({bool showAppBar = true}) =>
      PrivacyPolicyScreen(showAppBar: showAppBar);

  @override
  Widget deleteAccUsecaseScreen() => const DelAccScreen();

  @override
  Widget createDonateLightningScreen() => const DonateLightningScreen();

  @override
  Widget createExportImportScreen() => const ExportImportScreen();

  @override
  Widget createApkDistributionScreen({bool showAppBar = true}) =>
      ApkDistributionScreen(showAppBar: showAppBar);
}
