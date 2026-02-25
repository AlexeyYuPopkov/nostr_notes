import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:nostr_notes/core/event_kind.dart';
import 'package:nostr_notes/services/event_store/database/app_database.dart';
import 'package:nostr_notes/services/event_store/database/tables/nostr_events.dart';
import 'package:nostr_notes/services/event_store/database/tables/nostr_tags.dart';
import 'package:nostr_notes/services/event_store/raw_event_store.dart';
import 'package:nostr_notes/services/model/nostr_event.dart';
import 'package:nostr_notes/services/model/tag/tag.dart';
import 'package:nostr_notes/services/model/tag/tag_value.dart';

import '../tables/nostr_event_relays.dart';

part 'nostr_event_dao.g.dart';

@DriftAccessor(tables: [NostrEvents, NostrTags, NostrEventRelays])
class NostrEventDao extends DatabaseAccessor<AppDatabase>
    with _$NostrEventDaoMixin {
  NostrEventDao(super.db);

  Future<void> upsertEvents(
    Iterable<NostrEvent> events, {
    String? relayUrl,
  }) async {
    if (events.isEmpty) return;

    await transaction(() async {
      final nowMs = DateTime.now().millisecondsSinceEpoch;

      // Pre-filter: skip replaceable events where DB already has a newer
      // version. This must happen before the batch because batch operations
      // cannot perform conditional queries.
      final eventsToUpsert = await _filterStaleReplaceableEvents(events);

      await batch((b) {
        if (eventsToUpsert.isNotEmpty) {
          final eventIds = eventsToUpsert.map((e) => e.id).toSet();

          // 1) Upsert events in bulk
          for (final e in eventsToUpsert) {
            /// Delete previous version of replaceable event
            ///
            if (e.kind >= 10000 && e.kind < 20000 ||
                e.kind == 0 ||
                e.kind == 3) {
              b.deleteWhere(
                nostrEvents,
                (events) =>
                    events.kind.equals(e.kind) & events.pubkey.equals(e.pubkey),
              );
            } else if (e.kind >= 30000 && e.kind < 40000) {
              final dTag = e.getDTag();
              if (dTag != null && dTag.isNotEmpty) {
                // Addressable events: delete by kind + pubkey + d-tag
                final subquery = selectOnly(nostrTags)
                  ..addColumns([nostrTags.eventId])
                  ..where(
                    nostrTags.tag.equals('d') & nostrTags.value.equals(dTag),
                  );

                b.deleteWhere(
                  nostrEvents,
                  (events) =>
                      events.kind.equals(e.kind) &
                      events.pubkey.equals(e.pubkey) &
                      events.id.isInQuery(subquery),
                );
              }
            }

            b.insert(
              nostrEvents,
              NostrEventsCompanion(
                id: Value(e.id),
                kind: Value(e.kind),
                pubkey: Value(e.pubkey),
                createdAt: Value(e.createdAt),
                receivedAt: Value(nowMs),
                content: Value(e.content),
                sig: Value(e.sig),
                tags: Value(jsonEncode(e.tags)),
              ),
              mode: InsertMode.insertOrReplace,
            );
          }

          // 2) Delete all tags for these events in one go
          b.deleteWhere(nostrTags, (t) => t.eventId.isIn(eventIds));

          // 3) Insert all tags for all events in one batch
          for (final e in eventsToUpsert) {
            if (e.tags.isEmpty) continue;

            for (final tag in e.tags) {
              if (tag.isEmpty) continue;

              final tagName = tag[0];
              final tagValue = tag.length >= 2 ? tag[1] : '';
              final extras = tag.length > 2 ? tag.sublist(2) : [];

              b.insert(
                nostrTags,
                NostrTagsCompanion.insert(
                  eventId: e.id,
                  tag: tagName,
                  value: tagValue,
                  extraJson: Value(extras.isEmpty ? null : jsonEncode(extras)),
                ),
              );
            }
          }
        }

        // 4) Relay info for ALL incoming events (not just upserted),
        // so we track which relays have the event even if we already
        // have a newer version stored.
        if (relayUrl != null) {
          for (final e in events) {
            b.insert(
              nostrEventRelays,
              NostrEventRelaysCompanion.insert(
                eventId: e.id,
                relayUrl: relayUrl,
                firstSeenAt: nowMs,
              ),
              mode: InsertMode.insertOrIgnore,
            );
          }
        }
      });

      // 5) Handle kind=5 deletion events (NIP-09):
      // delete referenced events by e-tag and a-tag.
      for (final delEvent in eventsToUpsert) {
        if (delEvent.kind == NostrKind.deletion) {
          await _handleDeletionEvent(delEvent);
        }
      }
    });
  }

  /// NIP-09: handles a deletion event by removing referenced events.
  /// - e-tags: delete events by ID (same author only)
  /// - a-tags: delete addressable events by kind+pubkey+d-tag
  ///   where created_at <= deletion's created_at
  /// Must be called inside a transaction.
  Future<void> _handleDeletionEvent(NostrEvent delEvent) async {
    final delPubkey = delEvent.pubkey;
    final delCreatedAtSec = delEvent.createdAt;
    final idsToDelete = <String>{};

    // 1) e-tags: delete specific events by ID (same author only)
    final eTagIds = delEvent.getTagsSet(Tag.e);
    if (eTagIds.isNotEmpty) {
      final rows =
          await (select(nostrEvents)..where(
                (e) => e.id.isIn(eTagIds.toList()) & e.pubkey.equals(delPubkey),
              ))
              .get();
      idsToDelete.addAll(rows.map((r) => r.id));
    }

    // 2) a-tags: delete addressable events by kind+pubkey+d-tag
    final aTags = delEvent.getTagsSet(Tag.a);
    for (final aTag in aTags) {
      final parts = aTag.split(':');
      if (parts.length < 3) continue;

      final kind = int.tryParse(parts[0]);
      final pubkey = parts[1];
      final dIdentifier = parts[2];
      if (kind == null) continue;
      // Only the same author can delete their own events
      if (pubkey != delPubkey) continue;

      final dTagSubquery = selectOnly(nostrTags)
        ..addColumns([nostrTags.eventId])
        ..where(
          nostrTags.tag.equals(TagValue.d) &
              nostrTags.value.equals(dIdentifier),
        );

      final rows =
          await (select(nostrEvents)..where(
                (e) =>
                    e.kind.equals(kind) &
                    e.pubkey.equals(pubkey) &
                    e.id.isInQuery(dTagSubquery) &
                    e.createdAt.isSmallerOrEqualValue(delCreatedAtSec),
              ))
              .get();
      idsToDelete.addAll(rows.map((r) => r.id));
    }

    if (idsToDelete.isEmpty) return;

    final idList = idsToDelete.toList();
    await batch((b) {
      b.deleteWhere(nostrTags, (t) => t.eventId.isIn(idList));
      b.deleteWhere(nostrEventRelays, (r) => r.eventId.isIn(idList));
      b.deleteWhere(nostrEvents, (e) => e.id.isIn(idList));
    });
  }

  /// Filters out replaceable/parameterized-replaceable events where the DB
  /// already stores a version with a newer or equal `created_at`.
  /// Must be called inside a transaction for read consistency.
  Future<List<NostrEvent>> _filterStaleReplaceableEvents(
    Iterable<NostrEvent> events,
  ) async {
    final result = <NostrEvent>[];

    for (final e in events) {
      if (e.kind == 10008) {
        // Multiple kind 10008 events per author are kept, no replacement.
        result.add(e);
      } else if (e.kind >= 10000 && e.kind < 20000 ||
          e.kind == 0 ||
          e.kind == 3) {
        // Replaceable: check by kind + pubkey
        final existing =
            await (select(nostrEvents)
                  ..where(
                    (tbl) =>
                        tbl.kind.equals(e.kind) & tbl.pubkey.equals(e.pubkey),
                  )
                  ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
                  ..limit(1))
                .getSingleOrNull();

        if (existing == null || e.createdAt > existing.createdAt) {
          result.add(e);
        }
      } else if (e.kind >= 30000 && e.kind < 40000) {
        final dTag = e.getDTag();
        if (dTag == null || dTag.isEmpty) {
          result.add(e);
        } else {
          // Parameterized replaceable: check by kind + pubkey + d-tag
          final tagSubquery = selectOnly(nostrTags)
            ..addColumns([nostrTags.eventId])
            ..where(nostrTags.tag.equals('d') & nostrTags.value.equals(dTag));

          final existing =
              await (select(nostrEvents)
                    ..where(
                      (tbl) =>
                          tbl.kind.equals(e.kind) &
                          tbl.pubkey.equals(e.pubkey) &
                          tbl.id.isInQuery(tagSubquery),
                    )
                    ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
                    ..limit(1))
                  .getSingleOrNull();

          if (existing == null || e.createdAt > existing.createdAt) {
            result.add(e);
          }
        }
      } else {
        // Regular event: always keep.
        result.add(e);
      }
    }

    return result;
  }

  Future<List<NostrEvent>> queryEvents(RawEventQuery query) async {
    if (query.tagFilters == null || query.tagFilters!.isEmpty) {
      final selectStmt = _buildSimpleSelect(query);
      final rows = await selectStmt.get();
      return _mapEventRowsFromEvents(rows);
    } else {
      final joined = _buildJoinedSelect(query);
      final rows = await joined.get();
      final events = rows.map((r) => r.readTable(nostrEvents)).toList();
      return _mapEventRowsFromEvents(events);
    }
  }

  Stream<List<NostrEvent>> watchEvents(RawEventQuery query) {
    if (query.tagFilters == null || query.tagFilters!.isEmpty) {
      final selectStmt = _buildSimpleSelect(query);
      return selectStmt.watch().map(_mapEventRowsFromEvents);
    } else {
      final joined = _buildJoinedSelect(query);
      return joined.watch().map((rows) {
        final events = rows.map((r) => r.readTable(nostrEvents)).toList();
        return _mapEventRowsFromEvents(events);
      });
    }
  }

  // Simple select on nostr_events with no tag filters
  SimpleSelectStatement<NostrEvents, NostrEventData> _buildSimpleSelect(
    RawEventQuery query,
  ) {
    final q = select(nostrEvents);

    _applyCommonWhere(q, query);

    q.orderBy([(e) => OrderingTerm.desc(e.createdAt)]);

    if (query.limit != null) {
      q.limit(query.limit!);
    }

    return q;
  }

  // Joined select (nostr_events + nostr_tags aliases) for tagFilters (AND semantics)
  JoinedSelectStatement _buildJoinedSelect(RawEventQuery query) {
    final base = select(nostrEvents);

    final joins = <Join>[];

    for (final tf in query.tagFilters!) {
      // Use alias to allow multiple joins on the same table
      final aliasTable = alias(
        nostrTags,
        'tags_${tf.tag}_${tf.value.hashCode}',
      );

      joins.add(
        innerJoin(
          aliasTable,
          aliasTable.eventId.equalsExp(nostrEvents.id) &
              aliasTable.tag.equals(tf.tag) &
              aliasTable.value.isIn(tf.value),
        ),
      );
    }

    final joined = base.join(joins);

    _applyCommonWhereOnJoin(joined, query);

    joined.orderBy([OrderingTerm.desc(nostrEvents.createdAt)]);

    if (query.limit != null) {
      joined.limit(query.limit!);
    }

    return joined;
  }

  void _applyCommonWhere(
    SimpleSelectStatement<NostrEvents, NostrEventData> q,
    RawEventQuery query,
  ) {
    if (query.ids != null && query.ids!.isNotEmpty) {
      q.where((e) => e.id.isIn(query.ids!));
    }

    if (query.kinds != null && query.kinds!.isNotEmpty) {
      q.where((e) => e.kind.isIn(query.kinds!));
    }

    if (query.authors != null && query.authors!.isNotEmpty) {
      q.where((e) => e.pubkey.isIn(query.authors!));
    }

    if (query.since != null) {
      final sinceSec = query.since!.toUtc().millisecondsSinceEpoch ~/ 1000;
      q.where((e) => e.createdAt.isBiggerOrEqualValue(sinceSec));
    }

    if (query.until != null) {
      final untilSec = query.until!.toUtc().millisecondsSinceEpoch ~/ 1000;
      q.where((e) => e.createdAt.isSmallerOrEqualValue(untilSec));
    }

    if (query.search != null && query.search!.isNotEmpty) {
      final searchLower = query.search;

      // Subquery to find event IDs with matching tag values
      final tagSubquery = selectOnly(nostrTags)
        ..addColumns([nostrTags.eventId])
        ..where(nostrTags.value.like('%$searchLower%'));

      // Search in content OR in tag values
      q.where(
        (e) => e.content.like('%$searchLower%') | e.id.isInQuery(tagSubquery),
      );
    }

    // Filter events that have at least one tag of specified type(s)
    if (query.hasTagTypes != null && query.hasTagTypes!.isNotEmpty) {
      final hasTagSubquery = selectOnly(nostrTags)
        ..addColumns([nostrTags.eventId])
        ..where(nostrTags.tag.isIn(query.hasTagTypes!));

      q.where((e) => e.id.isInQuery(hasTagSubquery));
    }
  }

  void _applyCommonWhereOnJoin(
    JoinedSelectStatement joined,
    RawEventQuery query,
  ) {
    if (query.kinds != null && query.kinds!.isNotEmpty) {
      joined.where(nostrEvents.kind.isIn(query.kinds!));
    }

    if (query.authors != null && query.authors!.isNotEmpty) {
      joined.where(nostrEvents.pubkey.isIn(query.authors!));
    }

    if (query.since != null) {
      final sinceSec = query.since!.toUtc().millisecondsSinceEpoch ~/ 1000;
      joined.where(nostrEvents.createdAt.isBiggerOrEqualValue(sinceSec));
    }

    if (query.until != null) {
      final untilSec = query.until!.toUtc().millisecondsSinceEpoch ~/ 1000;
      joined.where(nostrEvents.createdAt.isSmallerOrEqualValue(untilSec));
    }

    if (query.search != null && query.search!.isNotEmpty) {
      final searchLower = query.search;

      // Subquery to find event IDs with matching tag values
      final tagSubquery = selectOnly(nostrTags)
        ..addColumns([nostrTags.eventId])
        ..where(nostrTags.value.like('%$searchLower%'));

      // Search in content OR in tag values
      joined.where(
        nostrEvents.content.like('%$searchLower%') |
            nostrEvents.id.isInQuery(tagSubquery),
      );
    }

    // Filter events that have at least one tag of specified type(s)
    if (query.hasTagTypes != null && query.hasTagTypes!.isNotEmpty) {
      final hasTagSubquery = selectOnly(nostrTags)
        ..addColumns([nostrTags.eventId])
        ..where(nostrTags.tag.isIn(query.hasTagTypes!));

      joined.where(nostrEvents.id.isInQuery(hasTagSubquery));
    }
  }

  List<NostrEvent> _mapEventRowsFromEvents(List<NostrEventData> rows) {
    return rows.map((row) {
      final decoded = jsonDecode(row.tags);
      final rawTags = decoded is List ? decoded : const [];

      final tags = rawTags
          .cast<List>()
          .map((e) => e.cast<String>().toList())
          .toList();

      return NostrEvent(
        id: row.id,
        kind: row.kind,
        pubkey: row.pubkey,
        createdAt: row.createdAt,
        content: row.content,
        sig: row.sig,
        tags: tags,
      );
    }).toList();
  }

  Future<Set<String>> filterMissingEventIds(Set<String> ids) async {
    if (ids.isEmpty) return <String>{};

    final idList = ids.toList();

    final existing = await (select(
      nostrEvents,
    )..where((e) => e.id.isIn(idList))).get();

    final existingIds = existing.map((e) => e.id).toSet();
    return ids.difference(existingIds);
  }

  Future<Set<String>> filterMissingPubkeys(Set<String> pubkeys) async {
    if (pubkeys.isEmpty) return <String>{};

    final pkList = pubkeys.toList();

    // “Profile exists” == we have at least one metadata event (kind 0) for this pubkey
    final existing = await (select(
      nostrEvents,
    )..where((e) => e.kind.equals(0) & e.pubkey.isIn(pkList))).get();

    final existingPubkeys = existing.map((e) => e.pubkey).toSet();
    return pubkeys.difference(existingPubkeys);
  }

  Future<Set<String>> filterMissingDTags(Set<String> dTags) async {
    if (dTags.isEmpty) return <String>{};

    final existing = await (select(
      nostrTags,
    )..where((t) => t.tag.equals('d') & t.value.isIn(dTags))).get();
    final existingDTags = existing.map((row) => row.value).toSet();

    return dTags.difference(existingDTags);
  }

  /// Deletes events by their IDs along with their associated tags and relay info.
  Future<void> deleteEvents(Set<String> ids) async {
    if (ids.isEmpty) return;

    final idList = ids.toList();

    await transaction(() async {
      await batch((b) {
        //TODO: mayby double work because `onDelete: KeyAction.cascade`
        // Delete tags first (foreign key reference)
        b.deleteWhere(nostrTags, (t) => t.eventId.isIn(idList));
        // Delete relay info
        b.deleteWhere(nostrEventRelays, (r) => r.eventId.isIn(idList));
        // Delete the events themselves
        b.deleteWhere(nostrEvents, (e) => e.id.isIn(idList));
      });
    });

    // Explicitly notify stream subscribers about table changes.
    // This is needed because batch operations within transactions may not
    // automatically trigger stream updates for joined queries.
    notifyUpdates({
      TableUpdate.onTable(nostrEvents, kind: UpdateKind.delete),
      TableUpdate.onTable(nostrTags, kind: UpdateKind.delete),
      TableUpdate.onTable(nostrEventRelays, kind: UpdateKind.delete),
    });
  }
}
