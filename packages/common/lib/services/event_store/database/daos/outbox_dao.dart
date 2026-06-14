import 'package:drift/drift.dart';
import 'package:common/services/event_store/database/app_database.dart';
import 'package:common/services/event_store/database/tables/outbox_events.dart';

import 'outbox_dao_interface.dart';

part 'outbox_dao.g.dart';

/// The outbox is a plain delivery queue: a row exists iff the event still needs
/// to reach relays. On success the row is removed.
///
/// The legacy `status` column is no longer written (rows stay at the default
/// `pending`); queries simply exclude any pre-existing `sent` rows from older
/// app versions so already-delivered events are not resurfaced.
@DriftAccessor(tables: [OutboxEvents])
class OutboxDao extends DatabaseAccessor<AppDatabase>
    with _$OutboxDaoMixin
    implements OutboxDaoInterface {
  OutboxDao(super.db);

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

  @override
  Future<List<OutboxEventData>> getPending() async {
    return (select(outboxEvents)
          ..where((o) => o.status.isNotValue(OutboxStatus.sent.index))
          ..orderBy([(o) => OrderingTerm.asc(o.createdAt)]))
        .get();
  }

  @override
  Stream<List<OutboxEventData>> watchUndelivered() {
    return (select(outboxEvents)
          ..where((o) => o.status.isNotValue(OutboxStatus.sent.index))
          ..orderBy([(o) => OrderingTerm.asc(o.createdAt)]))
        .watch();
  }

  @override
  Future<void> remove(String eventId) async {
    await (delete(outboxEvents)..where((o) => o.eventId.equals(eventId))).go();
  }

  @override
  Future<void> removeUndeliveredByEventIds(Set<String> eventIds) async {
    if (eventIds.isEmpty) return;
    await (delete(outboxEvents)..where(
          (o) =>
              o.eventId.isIn(eventIds) &
              o.status.isNotValue(OutboxStatus.sent.index),
        ))
        .go();
  }
}
