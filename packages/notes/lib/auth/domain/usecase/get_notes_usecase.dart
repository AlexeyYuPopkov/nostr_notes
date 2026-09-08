import 'package:nostr_notes/auth/domain/model/note.dart';

abstract interface class GetNotesUsecase {
  /// Notes as they change, already decrypted.
  Stream<List<Note>> execute();

  /// A one-shot read, still encrypted — callers that need plaintext decrypt
  /// it themselves so they can decide what a failure means.
  ///
  /// [dTags] are the notes' `d` tags, not Nostr event ids; omit it for all
  /// notes. Deleted notes are excluded either way.
  Future<List<Note>> executeAsync({Set<String>? dTags});
}
