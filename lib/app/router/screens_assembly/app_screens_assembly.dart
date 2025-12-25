import 'package:flutter/material.dart';
import 'package:nostr_notes/app/router/screens_assembly/screens_assembly.dart';
import 'package:nostr_notes/auth/presentation/model/path_params.dart';
import 'package:nostr_notes/auth/presentation/note_details_screen/note_details_screen.dart';
// import 'package:nostr_notes/auth/presentation/note_details_screen/note_details_screen.dart';
import 'package:nostr_notes/auth/presentation/note_preview_screen/note_preview_screen.dart';
import 'package:nostr_notes/auth/presentation/note_screen/note_screen_v2.dart';

final class AppScreensAssembly implements ScreensAssembly {
  const AppScreensAssembly();
  @override
  Widget createNoteScreen(PathParams pathParams) {
    return NoteScreenV2(pathParams: pathParams);
  }

  @override
  Widget createNotePreview(PathParams pathParams) {
    return NotePreviewScreen(pathParams: pathParams);
  }

  @override
  Widget createNoteDetailsScreen(PathParams pathParams) {
    return NoteDetailsScreen(pathParams: pathParams);
  }
}
