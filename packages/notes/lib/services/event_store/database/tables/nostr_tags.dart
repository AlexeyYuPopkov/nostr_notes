import 'package:drift/drift.dart';
import 'package:nostr_notes/services/event_store/database/tables/nostr_events.dart';

@TableIndex(name: 'idx_nostr_tags_tag_value', columns: {#tag, #value})
@TableIndex(name: 'idx_nostr_tags_event_id', columns: {#eventId})
@DataClassName('NostrTagData')
class NostrTags extends Table {
  IntColumn get id => integer().autoIncrement()();

  // FK to NostrEvents.id
  TextColumn get eventId =>
      text().references(NostrEvents, #id, onDelete: KeyAction.cascade)();

  // Single-character tag: 'e', 'p', 'a', 'd', etc.
  TextColumn get tag => text()();

  // First tag value, e.g. event id, pubkey, a-value, etc.
  TextColumn get value => text()();

  // Optional: everything else in the tag serialized as JSON
  TextColumn get extraJson => text().nullable()();
}
