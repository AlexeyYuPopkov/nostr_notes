import 'package:flutter/material.dart';
import 'package:nostr_notes/auth/presentation/model/path_params.dart';

abstract interface class ScreensAssembly {
  Widget createNotePreview(PathParams pathParams);
  Widget createRawEventScreen(PathParamsEventId params);
  Widget createEditNoteMarkdownScreen(PathParams? pathParams);
  Widget createAppSettingsScreen();
  Widget createRelaysListScreen();
  Widget createHelpScreen();
  Widget createContactsScreen({bool showAppBarLeading = true});
  Widget createPrivacyPolicyScreen();
  Widget deleteAccUsecaseScreen();
}
