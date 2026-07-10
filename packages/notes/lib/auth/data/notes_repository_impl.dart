import 'dart:async';
import 'package:common/tools/app_worker/app_worker.dart';
import 'package:nostr/model/nostr_event.dart';
import 'package:nostr/model/nostr_event_with_relay.dart';
import 'package:nostr/model/nostr_filter.dart';
import 'package:nostr/model/nostr_req.dart';
import 'package:nostr/model/tag/tag.dart';
import 'package:nostr/model/tag/tag_value.dart';
import 'package:nostr/nostr_client/nostr_client.dart';
import 'package:nostr/nostr_client/nostr_event_creator.dart';
import 'package:nostr/nostr_client/nostr_publisher.dart';
import 'package:nostr/nostr_client/publish_event_report.dart';
import 'package:nostr_notes/app/app_config.dart';
import 'package:nostr_notes/auth/data/mappers/note_mapper.dart';
import 'package:nostr_notes/auth/domain/model/label.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/auth/domain/repo/notes_repository.dart';
import 'package:common/domain/error/app_error.dart';
import 'package:nostr_notes/core/event_kind.dart';

import 'package:nostr_notes/core/tools/date_time_helper.dart';
import 'package:nostr_notes/core/tools/now.dart';
import 'package:common/services/event_store/database/daos/outbox_dao_interface.dart';
import 'package:common/services/event_store/raw_event_store.dart';
import 'package:rxdart/transformers.dart';
import 'package:uuid/uuid.dart';

class NotesRepositoryImpl implements NotesRepository {
  final NostrClient _client;
  final RawEventStore _eventStore;
  final OutboxDaoInterface _outboxDao;
  final NostrEventCreator _eventCreator;
  final Now _now;

  const NotesRepositoryImpl({
    required NostrClient client,
    required RawEventStore eventStore,
    required OutboxDaoInterface outboxDao,
    NostrEventCreator eventCreator = const NostrEventCreator(),
    Now now = const Now(),
  }) : _client = client,
       _eventStore = eventStore,
       _outboxDao = outboxDao,
       _eventCreator = eventCreator,
       _now = now;

  @override
  void syncRelays(Set<String> newRelays) {
    final current = _client.relaysList.toSet();
    for (final removed in current.difference(newRelays)) {
      _client.removeRelay(removed);
    }
    _client.addRelays(newRelays.difference(current));
  }

  @override
  Stream<List> get eventsStream => _client
      .stream()
      .whereType<NostrEventWithRelay>()
      .bufferTime(const Duration(milliseconds: 100))
      .where((e) {
        return e.isNotEmpty;
      })
      .asyncMap((events) async {
        await _eventStore.upsert(events);
        return events;
      });

  @override
  void sendNotesRequest({
    required String pubkey,
    required Set<String> relays,
    DateTime? until,
  }) {
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
            additional: {
              '#k': [EventKind.note.value.toString()],
            },
            until: until?.toSecondsSinceEpoch(),
          ),
        ],
      ),
    );
  }

  @override
  void sendNoteRequest({
    required String id,
    required Set<String> relays,
    DateTime? until,
  }) {
    _client.addRelays(relays);

    _client.sendRequestToAll(
      NostrReq(
        filters: [
          NostrFilter(
            kinds: [EventKind.note.value],
            d: [id],
            until: until?.toSecondsSinceEpoch(),
          ),
        ],
      ),
    );
  }

  @override
  Future<Iterable<Note>> getNotes({required String pubkey}) async {
    final rawResult = await _eventStore.queryEvents(
      RawEventQuery(
        authors: [pubkey],
        kinds: [EventKind.note.value],
        tagFilters: [
          TagFilter(Tag.p.value, [pubkey]),
        ],
      ),
    );

    final deleted = await _eventStore.queryEvents(
      RawEventQuery(authors: [pubkey], kinds: const [NostrKind.deletion]),
    );

    return _performNotesFiltering(rawNotes: rawResult, deleted: deleted);
  }

  static Future<Iterable<Note>> _performNotesFiltering({
    required Iterable<NostrEvent> rawNotes,
    required Iterable<NostrEvent> deleted,
  }) async {
    return AppWorker.instance.compute(
      params: (rawNotes, deleted),
      callback: _performNotesFilteringIsolateEntry,
    );
  }

  static Iterable<Note> _performNotesFilteringIsolateEntry(
    (Iterable<NostrEvent> rawNotes, Iterable<NostrEvent> deleted) params,
  ) {
    final deletedDTags = params.$2
        .where((e) => e.kind == NostrKind.deletion)
        .map(ATag.getAllFromEvent)
        .expand((aTags) => aTags)
        .map((aTag) => aTag.dTag)
        .toSet();

    final result = params.$1.where((e) => e.content.isNotEmpty).where((e) {
      final dTag = e.getDTag();
      if (dTag == null || dTag.isEmpty) {
        return false;
      }

      return !deletedDTags.contains(dTag);
    }).nonNulls;

    return NoteMapper.fromNostrEvents(result);
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
          final deleted = await _eventStore.queryEvents(
            RawEventQuery(authors: [pubkey], kinds: const [NostrKind.deletion]),
          );

          return _performNotesFiltering(rawNotes: items, deleted: deleted);
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
        .where((e) => e.content.isNotEmpty)
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
          TagFilter(Tag.p.value, [pubkey]),
          TagFilter(TagValue.d, [id]),
        ],
      ),
    );

    final e = result.where((e) => e.content.isNotEmpty).firstOrNull;

    return e == null ? null : NoteMapper.fromNostrEvent(e);
  }

  @override
  Future<Note> publishNote({
    required Note note,
    required String pubkey,
    required String privateKey,
    required DateTime? initAt,
    required List<BaseLabel> labels,
    Now? now,
    Uuid? uuid,
  }) async {
    final dTagValue = note.dTag.isNotEmpty
        ? note.dTag
        : (uuid ?? const Uuid()).v1();

    final int? initAtSeconds = initAt == null
        ? null
        : (initAt.millisecondsSinceEpoch / 1000).floor();

    final List<List<String>> tags = [
      AppConfig.clientTagList(),
      [Tag.t.value, AppConfig.clientTagValue],
      [Tag.d.value, dTagValue],
      [Tag.p.value, pubkey],
      [const SummaryTag().value, note.summary],
      if (initAtSeconds != null) [Note.updatedAtTag, initAtSeconds.toString()],
      if (labels.isNotEmpty)
        [
          Note.labelsTag,
          ...[for (final label in labels) label.textValue],
        ],
    ];

    final createdAt = (now ?? _now).now();

    final event = _eventCreator.createEvent(
      kind: EventKind.note.value,
      content: note.content,
      createdAt: createdAt,
      tags: tags,
      pubkey: pubkey,
      privateKey: privateKey,
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

    final nowTime = (now ?? _now).now();
    // Ensure deletion event has createdAt strictly after the original note,
    // so upsert replaces the old replaceable event.
    final createdAt = nowTime.isAfter(note.createdAt)
        ? nowTime
        : note.createdAt.add(const Duration(seconds: 1));

    final List<List<String>> tags = [
      AppConfig.clientTagList(),
      [Tag.t.value, AppConfig.clientTagValue],
      [Tag.d.value, note.dTag],
      [Tag.p.value, pubkey],
    ];

    final event = _eventCreator.createEvent(
      kind: EventKind.note.value,
      content: '',
      createdAt: createdAt,
      tags: tags,
      pubkey: pubkey,
      privateKey: privateKey,
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
    }

    await _eventStore.upsert([event]);
    await _outboxDao.insert(eventId: event.id);

    unawaited(
      _maybeDelete(
        createdAt: createdAt,
        event: event,
        dTag: note.dTag,
        privateKey: privateKey,
      ),
    );

    return note;
  }

  Future<void> _maybeDelete({
    required DateTime createdAt,
    required NostrEvent event,
    required String dTag,
    required String privateKey,
  }) async {
    final deletion = _eventCreator.createEvent(
      kind: EventKind.delete.value,
      content: '',
      createdAt: createdAt,
      tags: [
        [TagValue.e, event.id],
        [
          TagValue.a,
          ATag(
            kind: EventKind.note.value,
            pubkey: event.pubkey,
            dTag: dTag,
          ).toTagString(),
        ],
      ],
      pubkey: event.pubkey,
      privateKey: privateKey,
    );

    await _eventStore.upsert([deletion]);
    await _outboxDao.insert(eventId: deletion.id);
  }

  @override
  Stream<NotesRepositoryRelayError> get relayErrors => _client.relayErrors.map(
    (e) => NotesRepositoryRelayError(relayUrl: e.relayUrl, parentError: e),
  );

  @override
  Future<ATagsAndIds> collectATags({required String pubkey}) async {
    final events = await _eventStore.queryEvents(
      RawEventQuery(
        authors: [pubkey],
        kinds: [EventKind.note.value],
        tagFilters: [
          TagFilter(Tag.p.value, [pubkey]),
        ],
      ),
    );

    final ids = <String>{};
    final aTags = <ATag>[];

    for (final e in events) {
      ids.add(e.id);
      final dTag = e.getDTag();
      if (dTag != null && dTag.isNotEmpty) {
        aTags.add(ATag(kind: e.kind, pubkey: pubkey, dTag: dTag));
      }
    }

    return ATagsAndIds(aTags: aTags, ids: ids);
  }

  @override
  Future<PublishEventReport?> deletionRequest({
    required ATagsAndIds aTags,
    required String publicKey,
    required String privateKey,
    required Set<String> relays,
  }) async {
    if (aTags.aTags.isEmpty) {
      return null;
    }
    final nowTime = _now.now();

    final event = _eventCreator.createEvent(
      kind: NostrKind.deletion,
      content: '',
      createdAt: nowTime,
      pubkey: publicKey,
      privateKey: privateKey,
      tags: [
        ...aTags.aTags.map((aTag) => aTag.toEventTag()),
        [Tag.k.value, EventKind.note.value.toString()],
      ],
    );

    await _eventStore.upsert([event]);
    _client.addRelays(relays);
    final publisher = NostrPublisher(client: _client, event: event);

    final report = await publisher.execute();

    return report;
  }

  @override
  Future<void> clearLocalStorages({
    required String pubkey,
    required ATagsAndIds aTags,
  }) {
    return Future.wait([
      _eventStore.deleteEvents(aTags.ids),
      _outboxDao.removeUndeliveredByEventIds(aTags.ids),
    ]).then((_) => null);
  }
}
