import 'package:flutter/material.dart';
import 'package:nostr_notes/auth/presentation/model/path_params.dart';

abstract interface class ScreensAssembly {
  Widget createNotePreview(PathParams pathParams);
  Widget createRawEventScreen(PathParamsEventId params);
  Widget createEditNoteMarkdownScreen(PathParams? pathParams);
  Widget createAppSettingsScreen();
  Widget createRelaysListScreen();
  Widget createHelpScreen();
  Widget createContactsScreen({bool showAppBar = true});
  Widget createPrivacyPolicyScreen({bool showAppBar = true});
  Widget deleteAccUsecaseScreen();
  Widget createDonateLightningScreen();
  Widget createExportImportScreen();
  Widget createApkDistributionScreen({bool showAppBar = true});
}
