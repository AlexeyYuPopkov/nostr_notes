import 'package:common/services/event_store/database/app_database.dart';

/// Interface for OutboxDao to enable testing with mocks.
///
/// The outbox is a plain delivery queue: **a row exists iff the event still
/// needs to reach relays.** Successfully delivered events are removed.
abstract interface class OutboxDaoInterface {
  /// Queue an event for publishing.
  Future<void> insert({required String eventId});

  /// Get all events still awaiting delivery, oldest first.
  Future<List<OutboxEventData>> getPending();

  /// Watch events still awaiting delivery (drives the "not yet delivered" UI).
  Stream<List<OutboxEventData>> watchUndelivered();

  /// Remove a delivered event from the outbox.
  Future<void> remove(String eventId);

  /// Remove outbox entries by event IDs (e.g. when a note is replaced/deleted).
  Future<void> removeUndeliveredByEventIds(Set<String> eventIds);
}
