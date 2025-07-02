import 'dart:async';

import 'package:collection/collection.dart';
import 'package:nostr_notes/app/app_config.dart';
import 'package:nostr_notes/auth/data/common_event_storage_impl.dart';
import 'package:nostr_notes/auth/data/mappers/note_mapper.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/auth/domain/repo/notes_repository.dart';
import 'package:nostr_notes/auth/domain/repo/relays_list_repo.dart';
import 'package:nostr_notes/common/domain/error/app_error.dart';
import 'package:nostr_notes/common/domain/event_publisher.dart';
import 'package:nostr_notes/core/event_kind.dart';
import 'package:nostr_notes/core/tools/date_time_helper.dart';
import 'package:nostr_notes/core/tools/now.dart';
import 'package:nostr_notes/services/model/nostr_event.dart';
import 'package:nostr_notes/services/model/nostr_filter.dart';
import 'package:nostr_notes/services/model/nostr_req.dart';
import 'package:nostr_notes/services/model/tag/tag.dart';
import 'package:nostr_notes/services/model/tag/tag_value.dart';
import 'package:nostr_notes/services/nostr_client.dart';
import 'package:nostr_notes/services/nostr_event_creator.dart';
import 'package:rxdart/transformers.dart';
import 'package:uuid/uuid.dart';

class NotesRepositoryImpl implements NotesRepository {
  final NostrClient client;
  // final EventPublisher _eventPublisher;
  final CommonEventStorage memoryStorage;
  final RelaysListRepo _relaysListRepo;

  const NotesRepositoryImpl({
    required this.client,
    required this.memoryStorage,
    required RelaysListRepo relaysListRepo,
  }) : _relaysListRepo = relaysListRepo;

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
    DateTime? until,
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
            until: until?.toSecondsSinceEpoch(),
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
          (e) => NoteMapper.fromNostrEvent(e),
        )
        .nonNulls;
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
        .sorted((a, b) => b.createdAt.compareTo(a.createdAt))
        .firstOrNull;

    return e == null ? null : NoteMapper.fromNostrEvent(e);
  }

  @override
  Future<EventPublisherResult> publishNote({
    required Note note,
    required String pubkey,
    required String privateKey,
    Now? now,
    Uuid? uuid,
    List<int>? randomBytes,
  }) async {
    final dTagValue =
        note.dTag.isNotEmpty ? note.dTag : (uuid ?? const Uuid()).v1();

    final List<List<String>> tags = [
      AppConfig.clientTagList(),
      [Tag.t.value, AppConfig.clientTagValue],
      [Tag.d.value, dTagValue],
      [
        Tag.p.value,
        pubkey,
      ],
      [const SummaryTag().value, note.summary],
    ];

    final createdAt = (now ?? const Now()).now();

    final event = NostrEventCreator.createEvent(
      kind: EventKind.note.value,
      content: note.content,
      createdAt: createdAt,
      tags: tags,
      pubkey: pubkey,
      privateKey: privateKey,
      randomBytes: randomBytes,
    );

    for (final relay in _relaysListRepo.getRelaysList()) {
      client.addRelay(relay);
    }

    await client.connect();

    final result = await client.publishEventToAll(event);

    final timeoutError = result.timeoutError;

    memoryStorage.add(result.targetEvent);

    // final resultNote = await getNote(
    //   pubkey: pubkey,
    //   privateKey: privateKey,
    //   id: note.dTag,
    // );

    final resultNote = NoteMapper.fromNostrEvent(result.targetEvent);

    if (resultNote == null) {
      throw const AppError.undefined();
    }

    return EventPublisherResult(
      reports: result.events
          .map(
            (e) => PublishReport(
              relay: e.relay,
              errorMessage: e.message,
            ),
          )
          .toList(),
      targetNote: resultNote,
      error: timeoutError == null
          ? null
          : PublishTimeoutError(parentError: timeoutError),
    );
  }
}
