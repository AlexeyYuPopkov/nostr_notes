import 'package:flutter/material.dart';
import 'package:nostr_notes/app/router/screens_assembly/screens_assembly.dart';
import 'package:nostr_notes/auth/presentation/edit_note_markdown_screen/edit_note_markdown_screen.dart';
import 'package:nostr_notes/auth/presentation/edit_note_quill_screen/edit_note_quill_screen.dart';
import 'package:nostr_notes/auth/presentation/model/path_params.dart';
import 'package:nostr_notes/auth/presentation/note_preview_screen/note_preview_screen.dart';
import 'package:nostr_notes/auth/presentation/settings/app/app_settings_screen.dart';

final class AppScreensAssembly implements ScreensAssembly {
  const AppScreensAssembly();

  @override
  Widget createNotePreview(PathParams pathParams) {
    return NotePreviewScreen(pathParams: pathParams);
  }

  @override
  Widget createEditNoteQuillScreen(PathParams pathParams) {
    return EditQuillNoteScreen(pathParams: pathParams);
  }

  @override
  Widget createEditNoteMarkdownScreen(PathParams pathParams) {
    return EditMarkdownNoteScreen(pathParams: pathParams);
  }

  @override
  Widget createAppSettingsScreen() => AppSettingsScreen();
}
