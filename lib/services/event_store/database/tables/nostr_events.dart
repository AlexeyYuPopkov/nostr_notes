import 'package:drift/drift.dart';

@TableIndex(
  name: 'idx_nostr_events_kind_created_at',
  columns: {
    #kind,
    IndexedColumn(#createdAt, orderBy: OrderingMode.desc),
  },
)
@TableIndex(
  name: 'idx_nostr_events_pubkey_created_at',
  columns: {
    #pubkey,
    IndexedColumn(#pubkey, orderBy: OrderingMode.desc),
  },
)
@DataClassName('NostrEventData')
class NostrEvents extends Table {
  /// Nostr event id (32-byte hex string)
  TextColumn get id => text()();

  /// Kind, e.g. 1 (note), 7 (reaction), etc.
  IntColumn get kind => integer()();

  /// Pubkey of author
  TextColumn get pubkey => text()();

  /// Unix seconds from Nostr event `created_at`
  IntColumn get createdAt => integer()();

  /// When this event was added to the database (milliseconds)
  IntColumn get receivedAt => integer()();

  TextColumn get content => text()();

  /// Signature
  TextColumn get sig => text()();

  /// Serialized tags array
  TextColumn get tags => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
