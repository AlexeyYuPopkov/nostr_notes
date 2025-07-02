import 'package:nostr_notes/auth/domain/model/note.dart';

abstract interface class NotesRepository {
  void sendRequest({
    required String pubkey,
    required Set<String> relays,
    DateTime? until,
  });

  Stream<List> get eventsStream;

  Future<Iterable<Note>> getNotes({
    required String pubkey,
    required String privateKey,
  });

  Future<Note?> getNote({
    required String pubkey,
    required String privateKey,
    required String id,
  });
}
