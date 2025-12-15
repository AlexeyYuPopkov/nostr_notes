import 'package:flutter/material.dart';
import 'package:nostr_notes/app/router/screens_assembly/screens_assembly.dart';
import 'package:nostr_notes/auth/presentation/model/path_params.dart';
import 'package:nostr_notes/auth/presentation/note_screen/note_screen_v2.dart';

final class AppScreensAssembly implements ScreensAssembly {
  const AppScreensAssembly();
  @override
  Widget createNoteScreen(PathParams pathParams) {
    return NoteScreenV2(pathParams: pathParams);
  }
}
