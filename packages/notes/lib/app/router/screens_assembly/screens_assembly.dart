import 'package:flutter/material.dart';
import 'package:nostr_notes/auth/presentation/edit_note_markdown_screen/edit_note_markdown_screen.dart';
import 'package:nostr_notes/auth/presentation/login_item_form/bloc/login_item_details_params.dart';
import 'package:nostr_notes/auth/presentation/login_item_form/login_item_form_screen.dart';
import 'package:nostr_notes/auth/presentation/model/path_params.dart';
import 'package:nostr_notes/auth/presentation/note_preview_screen/note_preview_screen.dart';

abstract interface class ScreensAssembly {
  Widget createNotePreview(
    PathParams pathParams, {
    required NotePreviewScreenCoordinator coordinator,
  });
  Widget createRawEventScreen(PathParamsEventId params);

  Widget createEditNoteMarkdownScreen(
    PathParams? pathParams, {
    required EditMarkdownNoteScreenCoordinator coordinator,
  });
  Widget createAppSettingsScreen();
  Widget createRelaysListScreen();
  Widget createHelpScreen();
  Widget createContactsScreen({bool showAppBar = true});
  Widget createPrivacyPolicyScreen({bool showAppBar = true});
  Widget deleteAccUsecaseScreen();
  Widget createDonateLightningScreen();
  Widget createExportImportScreen();
  Widget createApkDistributionScreen({bool showAppBar = true});
  Widget createLoginItemFormScreen({
    required LoginItemDetailsParams params,
    required LoginItemFormScreenCoordinator coordinator,
  });
}
