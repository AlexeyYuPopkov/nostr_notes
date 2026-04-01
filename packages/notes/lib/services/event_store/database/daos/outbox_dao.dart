import 'package:drift/drift.dart';
import 'package:nostr_notes/services/event_store/database/app_database.dart';
import 'package:nostr_notes/services/event_store/database/tables/outbox_events.dart';

import 'outbox_dao_interface.dart';

part 'outbox_dao.g.dart';

@DriftAccessor(tables: [OutboxEvents])
class OutboxDao extends DatabaseAccessor<AppDatabase>
    with _$OutboxDaoMixin
    implements OutboxDaoInterface {
  OutboxDao(super.db);

  /// Insert a new event into the outbox for publishing
  @override
  Future<void> insert({required String eventId}) async {
    await into(outboxEvents).insert(
      OutboxEventsCompanion.insert(
        eventId: eventId,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }

  /// Get all pending events that need to be published
  @override
  Future<List<OutboxEventData>> getPending() async {
    return (select(outboxEvents)
          ..where((o) => o.status.equals(OutboxStatus.pending.index))
          ..orderBy([(o) => OrderingTerm.asc(o.createdAt)]))
        .get();
  }

  /// Watch pending events for reactive publishing
  @override
  Stream<List<OutboxEventData>> watchPending() {
    return (select(outboxEvents)
          ..where((e) => e.status.equals(OutboxStatus.pending.index))
          ..orderBy([(e) => OrderingTerm.asc(e.createdAt)]))
        .watch();
  }

  /// Watch all undelivered events (pending, broadcasting, failed)
  @override
  Stream<List<OutboxEventData>> watchUndelivered() {
    return (select(outboxEvents)
          ..where(
            (e) => e.status.isIn([
              OutboxStatus.pending.index,
              OutboxStatus.broadcasting.index,
              OutboxStatus.failed.index,
            ]),
          )
          ..orderBy([(e) => OrderingTerm.asc(e.createdAt)]))
        .watch();
  }

  /// Mark an event as currently being broadcast
  @override
  Future<void> markBroadcasting(String eventId) async {
    await (update(outboxEvents)..where((o) => o.eventId.equals(eventId))).write(
      OutboxEventsCompanion(
        status: const Value(OutboxStatus.broadcasting),
        lastAttemptAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  /// Mark an event as successfully sent
  @override
  Future<void> markSent(String eventId, {List<String>? confirmedRelays}) async {
    await (update(outboxEvents)..where((o) => o.eventId.equals(eventId))).write(
      OutboxEventsCompanion(
        status: const Value(OutboxStatus.sent),
        confirmedRelays: Value(confirmedRelays?.join(',') ?? ''),
      ),
    );
  }

  /// Mark an event as failed (attempt count managed by OutboxPublisher)
  @override
  Future<void> markFailed(String eventId, String reason) async {
    await (update(outboxEvents)..where((o) => o.eventId.equals(eventId))).write(
      OutboxEventsCompanion(
        status: const Value(OutboxStatus.failed),
        failureReason: Value(reason),
      ),
    );
  }

  /// Reset a failed event back to pending for retry, incrementing attempt count
  @override
  Future<void> retryFailed(String eventId) async {
    final current = await (select(
      outboxEvents,
    )..where((o) => o.eventId.equals(eventId))).getSingleOrNull();

    if (current == null) return;

    await (update(outboxEvents)..where((o) => o.eventId.equals(eventId))).write(
      OutboxEventsCompanion(
        status: const Value(OutboxStatus.pending),
        attemptCount: Value(current.attemptCount + 1),
        failureReason: const Value(null),
      ),
    );
  }

  /// Get all failed events
  @override
  Future<List<OutboxEventData>> getFailed() async {
    return (select(
      outboxEvents,
    )..where((o) => o.status.equals(OutboxStatus.failed.index))).get();
  }

  /// Retry all failed events
  @override
  Future<void> retryAllFailed() async {
    await (update(
      outboxEvents,
    )..where((o) => o.status.equals(OutboxStatus.failed.index))).write(
      const OutboxEventsCompanion(
        status: Value(OutboxStatus.pending),
        failureReason: Value(null),
      ),
    );
  }

  /// Delete a sent event from the outbox
  @override
  Future<void> deleteSent(String eventId) async {
    await (delete(outboxEvents)..where((o) => o.eventId.equals(eventId))).go();
  }

  /// Remove undelivered outbox entries by event IDs (pending, broadcasting, failed)
  @override
  Future<void> removeUndeliveredByEventIds(Set<String> eventIds) async {
    if (eventIds.isEmpty) return;
    await (delete(outboxEvents)..where(
          (o) =>
              o.eventId.isIn(eventIds) &
              o.status.isIn([
                OutboxStatus.pending.index,
                OutboxStatus.broadcasting.index,
                OutboxStatus.failed.index,
              ]),
        ))
        .go();
  }

  /// Clean up old sent events (older than specified duration)
  @override
  Future<int> cleanupOldSent({
    Duration olderThan = const Duration(days: 7),
  }) async {
    final cutoff = DateTime.now().subtract(olderThan).millisecondsSinceEpoch;
    return (delete(outboxEvents)..where(
          (o) =>
              o.status.equals(OutboxStatus.sent.index) &
              o.createdAt.isSmallerThanValue(cutoff),
        ))
        .go();
  }
}
