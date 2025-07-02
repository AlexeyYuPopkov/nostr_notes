import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/common/domain/event_publisher.dart';
import 'package:nostr_notes/core/tools/now.dart';
import 'package:uuid/uuid.dart';

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

  Future<EventPublisherResult> publishNote({
    required Note note,
    required String pubkey,
    required String privateKey,
    Now? now,
    Uuid? uuid,
    List<int>? randomBytes,
  });
}
