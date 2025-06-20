import 'dart:async';

import 'package:nostr_notes/app/app_config.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/auth/domain/repo/notes_repository.dart';
import 'package:nostr_notes/services/model/nostr_event.dart';
import 'package:nostr_notes/services/model/nostr_filter.dart';
import 'package:nostr_notes/services/model/nostr_req.dart';
import 'package:nostr_notes/services/nostr_client.dart';
import 'package:rxdart/transformers.dart';

class NotesRepositoryImpl implements NotesRepository {
  final NostrClient client;

  const NotesRepositoryImpl({
    required this.client,
  });

  @override
  Stream<NoteBase> get notesStream =>
      client.stream().whereType<NostrEvent>().map((e) {
        return Note(e.content);
      });

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
}
