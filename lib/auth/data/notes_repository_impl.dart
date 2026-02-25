import 'dart:async';

import 'package:nostr_notes/app/app_config.dart';
import 'package:nostr_notes/auth/data/mappers/note_mapper.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/auth/domain/repo/notes_repository.dart';
import 'package:nostr_notes/auth/domain/repo/relays_list_repo.dart';
import 'package:nostr_notes/common/domain/error/app_error.dart';
import 'package:nostr_notes/core/event_kind.dart';
import 'package:nostr_notes/core/tools/date_time_helper.dart';
import 'package:nostr_notes/core/tools/now.dart';
import 'package:nostr_notes/services/event_store/raw_event_store.dart';
import 'package:nostr_notes/services/model/nostr_event.dart';
import 'package:nostr_notes/services/model/nostr_filter.dart';
import 'package:nostr_notes/services/model/nostr_req.dart';
import 'package:nostr_notes/services/model/tag/tag.dart';
import 'package:nostr_notes/services/model/tag/tag_value.dart';
import 'package:nostr_notes/services/nostr_client/nostr_client.dart';
import 'package:nostr_notes/services/nostr_client/nostr_event_creator.dart';
import 'package:nostr_notes/services/nostr_client/nostr_publisher.dart';
import 'package:nostr_notes/services/nostr_client/publish_event_report.dart';
import 'package:rxdart/transformers.dart';
import 'package:uuid/uuid.dart';

class NotesRepositoryImpl implements NotesRepository {
  final NostrClient client;
  final RawEventStore _eventStore;
  final RelaysListRepo _relaysListRepo;

  const NotesRepositoryImpl({
    required this.client,
    required RawEventStore eventStore,
    required RelaysListRepo relaysListRepo,
  }) : _eventStore = eventStore,
       _relaysListRepo = relaysListRepo;

  @override
  Stream<List> get eventsStream => client
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
    client.addRelays(relays);

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
  Future<NotePublisherReport> publishNote({
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

    for (final relay in _relaysListRepo.getRelaysList()) {
      client.addRelay(relay);
    }

    final publisher = NostrPublisher(client: client, event: event);

    final report = await publisher.execute();

    if (report.error is NotPublished) {
      throw report.error!;
    }

    _eventStore.upsert([report.event]);

    final resultNote = NoteMapper.fromNostrEvent(report.event);

    if (resultNote == null) {
      throw const AppError.undefined();
    }

    return report.toEventPublisherReport(resultNote);
  }
}

extension on PublishEventReport {
  NotePublisherReport toEventPublisherReport(Note? note) {
    return NotePublisherReport(
      exceededTimeout: exceededTimeout,
      successfulRelays: events.map((e) => e.relay).toList(),
      closedRelays: close.map((e) => e.relay).toList(),
      note: note,
    );
  }
}
