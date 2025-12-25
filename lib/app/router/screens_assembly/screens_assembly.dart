import 'package:flutter/material.dart';
import 'package:nostr_notes/auth/presentation/model/path_params.dart';

abstract interface class ScreensAssembly {
  Widget createNoteScreen(PathParams pathParams);
  Widget createNotePreview(PathParams pathParams);
  Widget createNoteDetailsScreen(PathParams pathParams);
}
