import 'package:nostr_notes/services/event_store/database/app_database.dart';

/// Interface for OutboxDao to enable testing with mocks.
abstract interface class OutboxDaoInterface {
  /// Insert a new event into the outbox for publishing
  Future<void> insert({required String eventId});

  /// Get all pending events that need to be published
  Future<List<OutboxEventData>> getPending();

  /// Watch pending events for reactive publishing
  Stream<List<OutboxEventData>> watchPending();

  /// Mark an event as currently being broadcast
  Future<void> markBroadcasting(String eventId);

  /// Mark an event as successfully sent
  Future<void> markSent(String eventId, {List<String>? confirmedRelays});

  /// Mark an event as failed and increment attempt count
  Future<void> markFailed(String eventId, String reason);

  /// Reset a failed event back to pending for retry
  Future<void> retryFailed(String eventId);

  /// Get all failed events
  Future<List<OutboxEventData>> getFailed();

  /// Retry all failed events
  Future<void> retryAllFailed();

  /// Delete a sent event from the outbox
  Future<void> deleteSent(String eventId);

  /// Clean up old sent events (older than specified duration)
  Future<int> cleanupOldSent({Duration olderThan = const Duration(days: 7)});
}
