import 'package:nostr_notes/auth/domain/model/note.dart';
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

  Stream<Iterable<Note>> watchNotes({
    required String pubkey,
    required String privateKey,
  });

  Future<Note?> getNote({
    required String pubkey,
    required String privateKey,
    required String id,
  });

  Future<Note> publishNote({
    required Note note,
    required String pubkey,
    required String privateKey,
    Now? now,
    Uuid? uuid,
    List<int>? randomBytes,
  });
}

final class NotePublisherReport {
  final Duration? exceededTimeout;
  final List<String> successfulRelays;
  final List<String> closedRelays;
  final Note? note;

  NotePublisherReport({
    required this.exceededTimeout,
    required this.successfulRelays,
    required this.closedRelays,
    required this.note,
  });

  NotePublisherReport copyWith({Note? note}) {
    return NotePublisherReport(
      exceededTimeout: exceededTimeout,
      successfulRelays: successfulRelays,
      closedRelays: closedRelays,
      note: note ?? this.note,
    );
  }
}
