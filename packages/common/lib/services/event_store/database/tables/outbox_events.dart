import 'package:drift/drift.dart';

/// Status of an outbox event for relay publishing
enum OutboxStatus {
  /// Pending - waiting to be sent
  pending,

  /// Currently being sent to relays
  broadcasting,

  /// Successfully sent to at least one relay
  sent,

  /// Failed after max retries
  failed,
}

/// Outbox table for queuing Nostr events to be published to relays.
///
/// This enables the "SQL-first" pattern where the app writes to SQL
/// immediately and a background publisher sends to relays asynchronously.
@TableIndex(name: 'idx_outbox_status_created', columns: {#status, #createdAt})
@DataClassName('OutboxEventData')
class OutboxEvents extends Table {
  /// The Nostr event ID (FK to nostr_events.id)
  TextColumn get eventId => text()();

  /// Current status of the publish attempt
  IntColumn get status => intEnum<OutboxStatus>().withDefault(
    Constant(OutboxStatus.pending.index),
  )();

  /// When the event was queued for publishing (ms since epoch)
  IntColumn get createdAt => integer()();

  /// When the last publish attempt was made (ms since epoch)
  IntColumn get lastAttemptAt => integer().nullable()();

  /// Number of publish attempts made
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();

  /// Error message if status is failed
  TextColumn get failureReason => text().nullable()();

  /// JSON array of relay URLs that confirmed receipt
  TextColumn get confirmedRelays => text().nullable()();

  @override
  Set<Column> get primaryKey => {eventId};
}
