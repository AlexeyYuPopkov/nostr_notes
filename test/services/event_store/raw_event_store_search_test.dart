import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart' show NativeDatabase;
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_notes/core/tools/date_time_helper.dart';
import 'package:nostr_notes/services/event_store/database/app_database.dart';
import 'package:nostr_notes/services/event_store/database/daos/nostr_event_dao.dart';
import 'package:nostr_notes/services/event_store/drift_event_store.dart';
import 'package:nostr_notes/services/event_store/raw_event_store.dart';
import 'package:nostr_notes/services/model/nostr_event.dart';

void main() {
  late RawEventStore rawEventStore;
  late AppDatabase database;

  setUp(() async {
    database = AppDatabase.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    rawEventStore = DriftEventStore(dao: NostrEventDao(database));
  });

  tearDown(() async {
    await database.close();
  });

  group('RawEventStore search', () {
    test('search finds events by content and tags', () async {
      await rawEventStore.upsert([
        _createEvent(id: 'event1', content: 'HELLO World', tags: []),
        _createEvent(id: 'event2', content: 'Goodbye World', tags: []),
        _createEvent(
          id: 'event3',
          content: 'Something else',
          tags: [
            ['awesome_title', 'Hello Universe'],
          ],
        ),
      ]);

      final results = await rawEventStore.queryEvents(
        const RawEventQuery(search: 'hello'),
      );

      expect(results.length, 2);
      final ids = results.map((e) => e.id).toSet();
      expect(ids.containsAll(['event1', 'event3']), isTrue);
      expect(ids.contains('event2'), isFalse);
    });

    test('search finds events by content and tags. non-ASCII', () async {
      // Note: SQLite's lower() function only works with ASCII characters.
      // For Cyrillic and other Unicode characters, search is effectively
      // case-sensitive because SQLite doesn't lowercase non-ASCII.
      // This is a known SQLite limitation without ICU extension.

      await rawEventStore.upsert([
        _createEvent(id: 'event1', content: 'ПРИВЕТ World', tags: []),

        _createEvent(id: 'event2', content: 'Goodbye World', tags: []),
        _createEvent(
          id: 'event3',
          content: 'Something else',
          tags: [
            ['awesome_title', 'привет Universe'],
          ],
        ),
        _createEvent(id: 'event4', content: 'Привет World', tags: []),
        _createEvent(
          id: 'event5',
          content: 'Something else',
          tags: [
            ['awesome_title', 'Привет Universe'],
          ],
        ),
      ]);

      final results = await rawEventStore.queryEvents(
        const RawEventQuery(search: 'Привет'),
      );

      expect(results.length, 2);
      final ids = results.map((e) => e.id).toSet();
      expect(ids.containsAll(['event1', 'event3']), isFalse);
      expect(ids.contains('event2'), isFalse);
      expect(ids.containsAll(['event4', 'event5']), isTrue);
    });

    test('watchEvents emits updates when matching event is added', () async {
      // Initial event
      await rawEventStore.upsert([
        _createEvent(id: 'event1', content: 'Initial content', tags: []),
      ]);

      final stream = rawEventStore.watchEvents(
        const RawEventQuery(search: 'searchable'),
      );

      // Collect emissions
      final emissions = <List<NostrEvent>>[];
      final subscription = stream.listen(emissions.add);

      // Wait for initial emission
      await Future.delayed(const Duration(milliseconds: 10));

      // Add matching event
      await rawEventStore.upsert([
        _createEvent(
          id: 'event2',
          content: 'This is searchable content',
          tags: [],
        ),
      ]);

      // Wait for stream to emit
      await Future.delayed(const Duration(milliseconds: 10));

      await subscription.cancel();

      // Should have at least 2 emissions: initial (empty) and after adding match
      expect(emissions.length, greaterThanOrEqualTo(2));
      expect(emissions.last.length, 1);
      expect(emissions.last.first.id, 'event2');
    });
  });
}

NostrEvent _createEvent({
  required String id,
  required String content,
  required List<List<String>> tags,
  int kind = 1,
  String pubkey = 'test_pubkey',
}) {
  return NostrEvent(
    id: id,
    kind: kind,
    content: content,
    sig: 'test_sig',
    pubkey: pubkey,
    createdAt: DateTime.now().toSecondsSinceEpoch(),
    tags: tags,
  );
}
