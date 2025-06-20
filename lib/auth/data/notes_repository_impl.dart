import 'dart:async';

import 'package:nostr_notes/app/app_config.dart';
import 'package:nostr_notes/auth/data/common_event_storage_impl.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/auth/domain/repo/notes_repository.dart';
import 'package:nostr_notes/services/model/nostr_event.dart';
import 'package:nostr_notes/services/model/nostr_filter.dart';
import 'package:nostr_notes/services/model/nostr_req.dart';
import 'package:nostr_notes/services/nostr_client.dart';
import 'package:rxdart/transformers.dart';

class NotesRepositoryImpl implements NotesRepository {
  final NostrClient client;
  final CommonEventStorage memoryStorage;

  const NotesRepositoryImpl({
    required this.client,
    required this.memoryStorage,
  });

  @override
  Stream<dynamic> get eventsStream => client
          .stream()
          .whereType<NostrEvent>()
          .bufferTime(
            const Duration(milliseconds: 50),
          )
          .map(
        (e) {
          if (e.isNotEmpty) {
            memoryStorage.addAll(e);
          }
        },
      );

  @override
  void sendRequest({
    required String pubkey,
    required Set<String> relays,
  }) {
    client.addRelays(relays);

    client.connect();
    client.sendRequestToAll(
      NostrReq(
        filters: [
          NostrFilter(
            kinds: const [4],
            authors: [pubkey],
            p: [pubkey],
            t: [AppConfig.clientTagValue],
          ),
        ],
      ),
    );
  }

  @override
  Future<Iterable<Note>> getNotes({
    required String pubkey,
  }) async {
    return memoryStorage.getEventsByAuthor(pubkey, 4).map(
          (e) => Note(
            content: e.content,
            createdAt: DateTime.fromMillisecondsSinceEpoch(e.createdAt * 1000),
          ),
        );
  }
}
