import 'dart:async';

import 'package:nostr_notes/app/app_config.dart';
import 'package:nostr_notes/auth/data/mappers/note_mapper.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/auth/domain/repo/notes_repository.dart';
import 'package:nostr_notes/common/domain/error/app_error.dart';
import 'package:nostr_notes/core/event_kind.dart';
import 'package:nostr_notes/core/tools/date_time_helper.dart';
import 'package:nostr_notes/core/tools/now.dart';
import 'package:nostr_notes/services/event_store/database/daos/outbox_dao_interface.dart';
import 'package:nostr_notes/services/event_store/raw_event_store.dart';
import 'package:nostr_notes/services/model/nostr_event.dart';
import 'package:nostr_notes/services/model/nostr_filter.dart';
import 'package:nostr_notes/services/model/nostr_req.dart';
import 'package:nostr_notes/services/model/tag/tag.dart';
import 'package:nostr_notes/services/model/tag/tag_value.dart';
import 'package:nostr_notes/services/nostr_client/nostr_client.dart';
import 'package:nostr_notes/services/nostr_client/nostr_event_creator.dart';
import 'package:rxdart/transformers.dart';
import 'package:uuid/uuid.dart';

class NotesRepositoryImpl implements NotesRepository {
  final NostrClient _client;
  final RawEventStore _eventStore;
  final OutboxDaoInterface _outboxDao;

  const NotesRepositoryImpl({
    required NostrClient client,
    required RawEventStore eventStore,
    required OutboxDaoInterface outboxDao,
  }) : _client = client,
       _eventStore = eventStore,
       _outboxDao = outboxDao;

  @override
  Stream<List> get eventsStream => _client
      .stream()
      .whereType<NostrEvent>()
      .bufferTime(const Duration(milliseconds: 100))
      .where((e) {
        return e.isNotEmpty;
      })
      .asyncMap((events) async {
        if (events.isNotEmpty) {
          await _eventStore.upsert(events);
        }
        return events;
      });

  @override
  void sendRequest({
    required String pubkey,
    required Set<String> relays,
    DateTime? until,
  }) async {
    _client.addRelays(relays);

    _client.sendRequestToAll(
      NostrReq(
        filters: [
          NostrFilter(
            kinds: [EventKind.note.value],
            authors: [pubkey],
            p: [pubkey],
            t: [AppConfig.clientTagValue],
            until: until?.toSecondsSinceEpoch(),
          ),
          NostrFilter(
            kinds: [EventKind.delete.value],
            authors: [pubkey],
            t: [AppConfig.clientTagValue],
            additional: {
              Tag.k.value: [EventKind.note.value],
            },
          ),
        ],
      ),
    );
  }

  @override
  Future<Iterable<Note>> getNotes({required String pubkey}) async {
    final result = await _eventStore.queryEvents(
      RawEventQuery(
        authors: [pubkey],
        kinds: [EventKind.note.value],
        tagFilters: [
          TagFilter(Tag.p.value, [pubkey]),
        ],
      ),
    );

    return result.map((e) => NoteMapper.fromNostrEvent(e)).nonNulls;
  }

  @override
  Stream<Iterable<Note>> watchNotes({required String pubkey}) {
    return _eventStore
        .watchEvents(
          RawEventQuery(
            authors: [pubkey],
            kinds: [EventKind.note.value],
            tagFilters: [
              TagFilter(Tag.p.value, [pubkey]),
            ],
          ),
        )
        .asyncMap((items) async {
          final result = await _eventStore.queryEvents(
            RawEventQuery(authors: [pubkey], kinds: [EventKind.delete.value]),
          );

          final aTags = result
              .map((e) => e.getATagComponents()?.dTag)
              .nonNulls
              .toSet();

          return items
              .where((e) => e.content.isNotEmpty)
              .where((e) => !aTags.contains(e.getDTag()))
              .map((e) => NoteMapper.fromNostrEvent(e))
              .nonNulls;
        });
  }

  @override
  Stream<Note> watchNote({required String pubkey, required String id}) {
    return _eventStore
        .watchEvents(
          RawEventQuery(
            authors: [pubkey],
            kinds: [EventKind.note.value],
            tagFilters: [
              TagFilter(Tag.p.value, [pubkey]),
              TagFilter(Tag.d.value, [id]),
            ],
            limit: 1,
          ),
        )
        .map((events) => events.firstOrNull)
        .whereNotNull()
        .distinct((a, b) => a.id == b.id)
        .map((e) => NoteMapper.fromNostrEvent(e))
        .whereNotNull();
  }

  @override
  Future<Note?> getNote({required String pubkey, required String id}) async {
    final result = await _eventStore.queryEvents(
      RawEventQuery(
        kinds: [EventKind.note.value],
        authors: [pubkey],
        tagFilters: [
          TagFilter(TagValue.d, [id]),
        ],
      ),
    );

    final e = result.firstOrNull;

    return e == null ? null : NoteMapper.fromNostrEvent(e);
  }

  @override
  Future<Note> publishNote({
    required Note note,
    required String pubkey,
    required String privateKey,
    Now? now,
    Uuid? uuid,
    List<int>? randomBytes,
  }) async {
    final dTagValue = note.dTag.isNotEmpty
        ? note.dTag
        : (uuid ?? const Uuid()).v1();

    final List<List<String>> tags = [
      AppConfig.clientTagList(),
      [Tag.t.value, AppConfig.clientTagValue],
      [Tag.d.value, dTagValue],
      [Tag.p.value, pubkey],
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

    // SQL-first: persist locally, then let OutboxPublisher handle relay sync
    // If editing an existing note (same dTag), remove old undelivered outbox entry
    if (note.dTag.isNotEmpty) {
      final previousEvents = await _eventStore.queryEvents(
        RawEventQuery(
          kinds: [EventKind.note.value],
          authors: [pubkey],
          tagFilters: [
            TagFilter(TagValue.d, [dTagValue]),
          ],
        ),
      );
      final oldEventIds = previousEvents
          .where((e) => e.id != event.id)
          .map((e) => e.id)
          .toSet();
      if (oldEventIds.isNotEmpty) {
        await _outboxDao.removeUndeliveredByEventIds(oldEventIds);
      }
    }

    await _eventStore.upsert([event]);
    await _outboxDao.insert(eventId: event.id);

    final resultNote = NoteMapper.fromNostrEvent(event);

    if (resultNote == null) {
      throw const AppError.undefined();
    }

    return resultNote;
  }

  @override
  Future<Note> deleteNote({
    required Note note,
    required String pubkey,
    required String privateKey,
    Now? now,
    Uuid? uuid,
    List<int>? randomBytes,
  }) async {
    if (note.dTag.isEmpty) {
      throw const AppError.common(
        message: 'Cannot delete a note without a dTag',
      );
    }

    final createdAt = (now ?? const Now()).now();

    final deletionEvent = NostrEventCreator.createEvent(
      kind: EventKind.delete.value,
      content: '',
      createdAt: createdAt,
      tags: [
        [Tag.a.value, '${EventKind.note.value}:$pubkey:${note.dTag}'],
        [Tag.k.value, '${EventKind.note.value}'],
      ],
      pubkey: pubkey,
      privateKey: privateKey,
      randomBytes: randomBytes,
    );

    // SQL-first: persist locally, then let OutboxPublisher handle relay sync
    // Remove old undelivered outbox entries and old events from store
    final previousEvents = await _eventStore.queryEvents(
      RawEventQuery(
        kinds: [EventKind.note.value],
        authors: [pubkey],
        tagFilters: [
          TagFilter(TagValue.d, [note.dTag]),
        ],
      ),
    );
    final oldEventIds = previousEvents.map((e) => e.id).toSet();
    if (oldEventIds.isNotEmpty) {
      await _outboxDao.removeUndeliveredByEventIds(oldEventIds);
      await _eventStore.deleteEvents(oldEventIds);
    }

    await _eventStore.upsert([deletionEvent]);
    await _outboxDao.insert(eventId: deletionEvent.id);

    return note;
  }

  @override
  Stream<NotesRepositoryRelayError> get relayErrors => _client.relayErrors.map(
    (e) => NotesRepositoryRelayError(relayUrl: e.relayUrl, parentError: e),
  );
}
