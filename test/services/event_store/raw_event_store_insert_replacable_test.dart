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
  late RawEventStore store;
  late AppDatabase database;

  const pk = 'pubkey_a';
  final jan = DateTime.utc(2025, 1, 1);
  final jun = DateTime.utc(2025, 6, 1);

  setUp(() async {
    database = AppDatabase.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    store = DriftEventStore(dao: NostrEventDao(database));
  });

  tearDown(() async {
    await database.close();
  });

  test('newer events replace older; older events are rejected', () async {
    // --- Initial batch: mix of all kinds (newer versions) ---
    final newerEvents = [
      _e(id: 'k0_new', kind: 0, pk: pk, at: jun, content: 'new profile'),
      _e(id: 'k3_new', kind: 3, pk: pk, at: jun, content: 'new contacts'),
      _e(id: 'k1_a', kind: 1, pk: pk, at: jan, content: 'regular note'),
      _e(
        id: 'sched_new',
        kind: 30402,
        pk: pk,
        at: jun,
        tags: [
          ['d', 'evt-1'],
          ['p', 'user1', '', 'Participant'],
          ['p', 'user2', '', 'Participant'],
        ],
      ),
    ];

    await store.upsert(newerEvents);

    // --- Second batch: stale versions of the same replaceable events ---
    final olderEvents = [
      _e(id: 'k0_old', kind: 0, pk: pk, at: jan, content: 'old profile'),
      _e(id: 'k3_old', kind: 3, pk: pk, at: jan, content: 'old contacts'),
      _e(
        id: 'sched_old',
        kind: 30402,
        pk: pk,
        at: jan,
        tags: [
          ['d', 'evt-1'],
        ],
      ),
    ];

    await store.upsert(olderEvents);

    // --- Assertions ---

    // kind 0: newer kept, older rejected
    final k0 = await store.queryEvents(
      const RawEventQuery(kinds: [0], authors: [pk]),
    );
    expect(k0, hasLength(1));
    expect(k0.first.id, 'k0_new');
    expect(k0.first.content, 'new profile');

    // kind 3: newer kept, older rejected
    final k3 = await store.queryEvents(
      const RawEventQuery(kinds: [3], authors: [pk]),
    );
    expect(k3, hasLength(1));
    expect(k3.first.id, 'k3_new');

    // kind 1: regular event untouched
    final k1 = await store.queryEvents(
      const RawEventQuery(kinds: [1], authors: [pk]),
    );
    expect(k1, hasLength(1));
    expect(k1.first.id, 'k1_a');

    // kind 30312: newer kept with p-tags, older rejected
    final sched = await store.queryEvents(
      const RawEventQuery(kinds: [30402], authors: [pk]),
    );
    expect(sched, hasLength(1));
    expect(sched.first.id, 'sched_new');
    final pTags = sched.first.tags.where((t) => t.first == 'p').toList();
    expect(pTags, hasLength(2), reason: 'p-tags must be preserved');
  });

  test('older events stored first are replaced by newer ones', () async {
    // --- Insert older versions first ---
    final olderEvents = [
      _e(id: 'k0_old', kind: 0, pk: pk, at: jan, content: 'old profile'),
      _e(id: 'k3_old', kind: 3, pk: pk, at: jan, content: 'old contacts'),
      _e(
        id: 'sched_old',
        kind: 30402,
        pk: pk,
        at: jan,
        tags: [
          ['d', 'evt-1'],
        ],
      ),
    ];

    await store.upsert(olderEvents);

    // --- Then insert newer versions ---
    final newerEvents = [
      _e(id: 'k0_new', kind: 0, pk: pk, at: jun, content: 'new profile'),
      _e(id: 'k3_new', kind: 3, pk: pk, at: jun, content: 'new contacts'),
      _e(
        id: 'sched_new',
        kind: 30402,
        pk: pk,
        at: jun,
        tags: [
          ['d', 'evt-1'],
          ['p', 'user1', '', 'Participant'],
        ],
      ),
    ];

    await store.upsert(newerEvents);

    // kind 0: replaced
    final k0 = await store.queryEvents(
      const RawEventQuery(kinds: [0], authors: [pk]),
    );
    expect(k0, hasLength(1));
    expect(k0.first.id, 'k0_new');

    // kind 3: replaced
    final k3 = await store.queryEvents(
      const RawEventQuery(kinds: [3], authors: [pk]),
    );
    expect(k3, hasLength(1));
    expect(k3.first.id, 'k3_new');

    // kind 30312: replaced, tags updated
    final sched = await store.queryEvents(
      const RawEventQuery(kinds: [30402], authors: [pk]),
    );
    expect(sched, hasLength(1));
    expect(sched.first.id, 'sched_new');
    expect(sched.first.tags.any((t) => t.first == 'p'), isTrue);
  });

  test(
    'different d-tags are independent; same created_at is rejected',
    () async {
      await store.upsert([
        _e(
          id: 'sched_a',
          kind: 30402,
          pk: pk,
          at: jun,
          tags: [
            ['d', 'd-tag-1'],
          ],
        ),
        _e(
          id: 'sched_b',
          kind: 30402,
          pk: pk,
          at: jun,
          tags: [
            ['d', 'd-tag-2'],
          ],
        ),
      ]);

      // Different d-tags → both stored
      final all = await store.queryEvents(
        const RawEventQuery(kinds: [30402], authors: [pk]),
      );
      expect(all, hasLength(2));

      // Same d-tag, same created_at → rejected
      await store.upsert([
        _e(
          id: 'sched_a_dup',
          kind: 30402,
          pk: pk,
          at: jun,
          tags: [
            ['d', 'd-tag-1'],
          ],
        ),
      ]);

      final afterDup = await store.queryEvents(
        const RawEventQuery(kinds: [30402], authors: [pk]),
      );
      expect(afterDup, hasLength(2));
      expect(afterDup.any((e) => e.id == 'sched_a'), isTrue);
      expect(afterDup.any((e) => e.id == 'sched_a_dup'), isFalse);
    },
  );
}

NostrEvent _e({
  required String id,
  required int kind,
  required String pk,
  required DateTime at,
  String content = '',
  List<List<String>> tags = const [],
}) {
  return NostrEvent(
    id: id,
    kind: kind,
    content: content,
    sig: 'test_sig',
    pubkey: pk,
    createdAt: at.toSecondsSinceEpoch(),
    tags: tags,
  );
}
