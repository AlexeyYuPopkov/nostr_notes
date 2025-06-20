import 'package:nostr_notes/auth/domain/model/note.dart';

abstract interface class NotesRepository {
  void sendRequest({
    required String pubkey,
    required Set<String> relays,
  });
  Stream<dynamic> get eventsStream;
  Future<Iterable<Note>> getNotes({required String pubkey});
}
