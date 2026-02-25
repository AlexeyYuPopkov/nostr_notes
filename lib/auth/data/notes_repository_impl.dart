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
        ],
      ),
    );
  }

  @override
  Future<Iterable<Note>> getNotes({
    required String pubkey,
    required String privateKey,
  }) async {
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
  Stream<Iterable<Note>> watchNotes({
    required String pubkey,
    required String privateKey,
  }) {
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
        .map(
          (items) => items.map((e) => NoteMapper.fromNostrEvent(e)).nonNulls,
        );
  }

  @override
  Future<Note?> getNote({
    required String pubkey,
    required String privateKey,
    required String id,
  }) async {
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
    await _eventStore.upsert([event]);
    await _outboxDao.insert(eventId: event.id);

    final resultNote = NoteMapper.fromNostrEvent(event);

    if (resultNote == null) {
      throw const AppError.undefined();
    }

    return resultNote;
  }
}
