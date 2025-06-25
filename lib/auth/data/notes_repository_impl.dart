import 'dart:async';

import 'package:collection/collection.dart';
import 'package:nostr_notes/app/app_config.dart';
import 'package:nostr_notes/auth/data/common_event_storage_impl.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/auth/domain/repo/notes_repository.dart';
import 'package:nostr_notes/core/event_kind.dart';
import 'package:nostr_notes/services/key_tool/nip04_service.dart';
import 'package:nostr_notes/services/model/nostr_event.dart';
import 'package:nostr_notes/services/model/nostr_filter.dart';
import 'package:nostr_notes/services/model/nostr_req.dart';
import 'package:nostr_notes/services/model/tag/tag.dart';
import 'package:nostr_notes/services/model/tag/tag_value.dart';
import 'package:nostr_notes/services/nostr_client.dart';
import 'package:rxdart/transformers.dart';

class NotesRepositoryImpl implements NotesRepository {
  final NostrClient client;
  final Nip04Service nip04;
  final CommonEventStorage memoryStorage;

  const NotesRepositoryImpl({
    required this.client,
    required this.nip04,
    required this.memoryStorage,
  });

  @override
  Stream<List> get eventsStream => client
          .stream()
          .whereType<NostrEvent>()
          .bufferTime(
            const Duration(milliseconds: 100),
          )
          .where((e) {
        return e.isNotEmpty;
      }).map(
        (e) {
          if (e.isNotEmpty) {
            memoryStorage.addAll(e);
          }
          return e;
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
            kinds: [EventKind.note.value],
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
    required String privateKey,
  }) async {
    return memoryStorage
        .getEventsByAuthor(
      pubkey,
      EventKind.note.value,
    )
        .map(
      (e) {
        final dTag = e.getFirstTag(Tag.d) ?? '';

        if (dTag.isEmpty) {
          return null;
        }
        final summaryTag = e.getFirstTag(const SummaryTag()) ?? '';

        final summary = summaryTag.isEmpty
            ? ''
            : nip04.decryptNip04(
                content: summaryTag,
                peerPubkey: e.pubkey,
                privateKey: privateKey,
              );

        return Note(
          dTag: dTag,
          content: e.content,
          summary: summary,
          createdAt: DateTime.fromMillisecondsSinceEpoch(e.createdAt * 1000),
        );
      },
    ).nonNulls;
  }

  @override
  Future<Note?> getNote({
    required String pubkey,
    required String privateKey,
    required String id,
  }) async {
    final aTag = TagValue.createATag(
      kind: EventKind.note.value,
      pubkey: pubkey,
      dTag: id,
    );
    final e = memoryStorage
        .getEventsByATag(
          aTag,
          EventKind.note.value,
        )
        .firstOrNull;
    final dTag = e?.getFirstTag(Tag.d) ?? '';

    assert(
      dTag.isNotEmpty,
      'dTag should not be empty for note with id: $id',
    );

    if (e == null || dTag.isEmpty) {
      return null;
    }

    final summaryTag = e.getFirstTag(const SummaryTag()) ?? '';

    final summary = summaryTag.isEmpty
        ? ''
        : nip04.decryptNip04(
            content: summaryTag,
            peerPubkey: e.pubkey,
            privateKey: privateKey,
          );

    final content = nip04.decryptNip04(
      content: e.content,
      peerPubkey: e.pubkey,
      privateKey: privateKey,
    );

    return Note(
      dTag: dTag,
      content: content,
      summary: summary,
      createdAt: DateTime.fromMillisecondsSinceEpoch(e.createdAt * 1000),
    );
  }
}
