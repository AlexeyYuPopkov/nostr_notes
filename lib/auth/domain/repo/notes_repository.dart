import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/common/domain/error/app_error.dart';
import 'package:nostr_notes/core/tools/now.dart';
import 'package:uuid/uuid.dart';

abstract interface class NotesRepository {
  void sendRequest({
    required String pubkey,
    required Set<String> relays,
    DateTime? until,
  });

  Stream<List> get eventsStream;

  Future<Iterable<Note>> getNotes({required String pubkey});

  Stream<Iterable<Note>> watchNotes({required String pubkey});

  Stream<Note> watchNote({required String pubkey, required String id});

  Future<Note?> getNote({required String pubkey, required String id});

  Future<Note> publishNote({
    required Note note,
    required String pubkey,
    required String privateKey,
    Now? now,
    Uuid? uuid,
    List<int>? randomBytes,
  });

  Stream<NotesRepositoryRelayError> get relayErrors;
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

final class NotesRepositoryRelayError extends AppError {
  final String relayUrl;

  @override
  String get message => 'Relay error on $relayUrl';

  const NotesRepositoryRelayError({required this.relayUrl, super.parentError});
}
