import 'package:drift/drift.dart';
import 'nostr_events.dart';

/// Tracks where did the event come from
@DataClassName('NostrEventRelayData')
class NostrEventRelays extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get eventId =>
      text().references(NostrEvents, #id, onDelete: KeyAction.cascade)();

  TextColumn get relayUrl => text()();

  IntColumn get firstSeenAt => integer()(); // ms since epoch

  @override
  List<Set<Column>>? get uniqueKeys => [
    {eventId, relayUrl},
  ];
}
