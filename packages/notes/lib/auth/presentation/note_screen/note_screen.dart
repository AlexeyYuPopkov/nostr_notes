// import 'package:common/app/theme/sizes.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:nostr_notes/auth/presentation/note_screen/edit_note_markdown_screen/edit_note_markdown_screen.dart';
// import 'package:nostr_notes/auth/presentation/note_screen/note_preview_screen/note_preview_screen.dart';

// final class NoteScreen extends StatefulWidget {
//    final NotePreviewScreenCoordinator coordinator;
//   const NoteScreen({super.key});

//   @override
//   State<NoteScreen> createState() => _NoteScreenState();
// }

// class _NoteScreenState extends State<NoteScreen> {
//   bool _isEditing = false;


//   @override
//   Widget build(BuildContext context) {
//     return AnimatedCrossFade(
//       firstChild:  NotePreviewScreen(),
//       secondChild:  EditMarkdownNoteScreen(),
//       crossFadeState: _isEditing
//           ? CrossFadeState.showSecond
//           : CrossFadeState.showFirst,
//       duration: AppDurations.medium,
//     );
//   }
// }