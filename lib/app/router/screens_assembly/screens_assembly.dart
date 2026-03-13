import 'package:flutter/material.dart';
import 'package:nostr_notes/auth/presentation/model/path_params.dart';

abstract interface class ScreensAssembly {
  Widget createNotePreview(PathParams pathParams);
  Widget createEditNoteQuillScreen(PathParams pathParams);
  Widget createEditNoteMarkdownScreen(PathParams? pathParams);
  Widget createAppSettingsScreen();
  Widget createRelaysListScreen();
  Widget createHelpScreen();
}
