import 'package:di_storage/di_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_notes/core/event_kind.dart';
import 'package:nostr_notes/core/tools/date_time_helper.dart';
import 'package:nostr_notes/services/event_store/database/app_database.dart';
import 'package:nostr_notes/services/event_store/raw_event_store.dart';
import 'package:nostr_notes/services/model/nostr_event.dart';
import 'package:nostr_notes/services/model/tag/tag_value.dart';

import '../../tools/di/in_memory_db_module.dart';

const _authorPubkey =
    '5f23c86b8dd9a3a3fd020d5f3f87293ffcba7e66b23437a164ed41f67d75f7ee';

const _targetPostId =
    'aaaa1111bbbb2222cccc3333dddd4444eeee5555ffff6666aaaa1111bbbb2222';

const _targetCommentId =
    'bbbb2222cccc3333dddd4444eeee5555ffff6666aaaa1111bbbb2222cccc3333';

void main() {
  late AppDatabase db;
  late RawEventStore rawEventStore;

  setUp(() {
    final di = DiStorage.shared;
    const InMemoryDbModule().bind(di);

    db = di.resolve();
    rawEventStore = di.resolve();
  });

  tearDown(() async {
    DiStorage.shared.removeAll();
    await db.close();
  });

  group('RawEventStore - handle deletion events (kind 5)', () {
    test('upserting kind=5 deletes referenced event by e-tag', () async {
      // Insert a post event
      final postEvent = NostrEvent(
        id: _targetPostId,
        pubkey: _authorPubkey,
        kind: 1,
        content: 'Hello world',
        sig: 'deadbeef',
        createdAt: DateTime(2025, 1, 17).toSecondsSinceEpoch(),
        tags: const [],
      );

      await rawEventStore.upsert([postEvent]);

      // Verify post is stored
      final beforeDeletion = await rawEventStore.queryEvents(
        const RawEventQuery(ids: [_targetPostId]),
      );
      expect(beforeDeletion, hasLength(1));

      // Insert deletion event referencing the post
      final deletionEvent = NostrEvent(
        id: 'deletion_event_001',
        pubkey: _authorPubkey,
        kind: 5,
        content: '',
        sig: 'deadbeef',
        createdAt: DateTime(2025, 1, 18).toSecondsSinceEpoch(),
        tags: const [
          [TagValue.e, _targetPostId],
        ],
      );

      await rawEventStore.upsert([deletionEvent]);

      // Post should be deleted from the store
      final afterDeletion = await rawEventStore.queryEvents(
        const RawEventQuery(ids: [_targetPostId]),
      );
      expect(afterDeletion, isEmpty);

      // Deletion event itself should be stored
      final deletionStored = await rawEventStore.queryEvents(
        const RawEventQuery(ids: ['deletion_event_001']),
      );
      expect(deletionStored, hasLength(1));
    });

    test('kind=5 with multiple e-tags deletes all referenced events', () async {
      final postEvent = NostrEvent(
        id: _targetPostId,
        pubkey: _authorPubkey,
        kind: 1,
        content: 'Post content',
        sig: 'deadbeef',
        createdAt: DateTime(2025, 1, 17).toSecondsSinceEpoch(),
        tags: const [],
      );

      final commentEvent = NostrEvent(
        id: _targetCommentId,
        pubkey: _authorPubkey,
        kind: 1,
        content: 'Comment content',
        sig: 'deadbeef',
        createdAt: DateTime(2025, 1, 17, 0, 1).toSecondsSinceEpoch(),
        tags: const [],
      );

      await rawEventStore.upsert([postEvent, commentEvent]);

      // Verify both stored
      final before = await rawEventStore.queryEvents(
        const RawEventQuery(ids: [_targetPostId, _targetCommentId]),
      );
      expect(before, hasLength(2));

      // Delete both via a single kind=5 event
      final deletionEvent = NostrEvent(
        id: 'deletion_event_002',
        pubkey: _authorPubkey,
        kind: 5,
        content: '',
        sig: 'deadbeef',
        createdAt: DateTime(2025, 1, 18).toSecondsSinceEpoch(),
        tags: const [
          [TagValue.e, _targetPostId],
          [TagValue.e, _targetCommentId],
        ],
      );

      await rawEventStore.upsert([deletionEvent]);

      final after = await rawEventStore.queryEvents(
        const RawEventQuery(ids: [_targetPostId, _targetCommentId]),
      );
      expect(after, isEmpty);
    });

    test('kind=5 only deletes events from the same author', () async {
      const otherAuthor =
          'cccc3333dddd4444eeee5555ffff6666aaaa1111bbbb2222cccc3333dddd4444';

      final postEvent = NostrEvent(
        id: _targetPostId,
        pubkey: otherAuthor,
        kind: 1,
        content: 'Other author post',
        sig: 'deadbeef',
        createdAt: DateTime(2025, 1, 17).toSecondsSinceEpoch(),
        tags: const [],
      );

      await rawEventStore.upsert([postEvent]);

      // Deletion from a different author should NOT delete the post
      final deletionEvent = NostrEvent(
        id: 'deletion_event_003',
        pubkey: _authorPubkey,
        kind: NostrKind.deletion,
        content: '',
        sig: 'deadbeef',
        createdAt: DateTime(2025, 1, 18).toSecondsSinceEpoch(),
        tags: const [
          [TagValue.e, _targetPostId],
        ],
      );

      await rawEventStore.upsert([deletionEvent]);

      // Post should still exist — different author
      final after = await rawEventStore.queryEvents(
        const RawEventQuery(ids: [_targetPostId]),
      );
      expect(after, hasLength(1));
    });

    test('kind=5 with a-tag deletes addressable event', () async {
      const dTag = 'my-listing-d-tag';
      const aTag = '${30402}:$_authorPubkey:$dTag';

      final listingEvent = NostrEvent(
        id: 'listing_event_001',
        pubkey: _authorPubkey,
        kind: 30402,
        content: 'Listing content',
        sig: 'deadbeef',
        createdAt: DateTime(2025, 1, 17).toSecondsSinceEpoch(),
        tags: const [
          [TagValue.d, dTag],
        ],
      );

      await rawEventStore.upsert([listingEvent]);

      // Verify listing is stored
      final before = await rawEventStore.queryEvents(
        const RawEventQuery(ids: ['listing_event_001']),
      );
      expect(before, hasLength(1));

      // Deletion event with a-tag
      final deletionEvent = NostrEvent(
        id: 'deletion_event_005',
        pubkey: _authorPubkey,
        kind: NostrKind.deletion,
        content: '',
        sig: 'deadbeef',
        createdAt: DateTime(2025, 1, 18).toSecondsSinceEpoch(),
        tags: const [
          [TagValue.a, aTag],
        ],
      );

      await rawEventStore.upsert([deletionEvent]);

      // Listing should be deleted
      final after = await rawEventStore.queryEvents(
        const RawEventQuery(ids: ['listing_event_001']),
      );
      expect(after, isEmpty);
    });

    test('kind=5 with a-tag from different author does not delete', () async {
      const otherAuthor =
          'cccc3333dddd4444eeee5555ffff6666aaaa1111bbbb2222cccc3333dddd4444';
      const dTag = 'my-listing-d-tag';
      // a-tag references the real author, but deletion is from otherAuthor
      const aTag = '${30402}:$_authorPubkey:$dTag';

      final listingEvent = NostrEvent(
        id: 'listing_event_002',
        pubkey: _authorPubkey,
        kind: 30402,
        content: 'Listing content',
        sig: 'deadbeef',
        createdAt: DateTime(2025, 1, 17).toSecondsSinceEpoch(),
        tags: const [
          [TagValue.d, dTag],
        ],
      );

      await rawEventStore.upsert([listingEvent]);

      // Deletion from a different author
      final deletionEvent = NostrEvent(
        id: 'deletion_event_007',
        pubkey: otherAuthor,
        kind: NostrKind.deletion,
        content: '',
        sig: 'deadbeef',
        createdAt: DateTime(2025, 1, 18).toSecondsSinceEpoch(),
        tags: const [
          [TagValue.a, aTag],
        ],
      );

      await rawEventStore.upsert([deletionEvent]);

      // Listing should still exist — different author
      final after = await rawEventStore.queryEvents(
        const RawEventQuery(ids: ['listing_event_002']),
      );
      expect(after, hasLength(1));
    });

    test('kind=5 with both e-tags and a-tags deletes all', () async {
      const dTag = 'listing-to-delete';
      const aTag = '${30402}:$_authorPubkey:$dTag';

      final postEvent = NostrEvent(
        id: _targetPostId,
        pubkey: _authorPubkey,
        kind: 1,
        content: 'Post to delete',
        sig: 'deadbeef',
        createdAt: DateTime(2025, 1, 17).toSecondsSinceEpoch(),
        tags: const [],
      );

      final listingEvent = NostrEvent(
        id: 'listing_event_003',
        pubkey: _authorPubkey,
        kind: 30402,
        content: 'Listing to delete',
        sig: 'deadbeef',
        createdAt: DateTime(2025, 1, 17).toSecondsSinceEpoch(),
        tags: const [
          [TagValue.d, dTag],
        ],
      );

      await rawEventStore.upsert([postEvent, listingEvent]);

      final deletionEvent = NostrEvent(
        id: 'deletion_event_008',
        pubkey: _authorPubkey,
        kind: NostrKind.deletion,
        content: '',
        sig: 'deadbeef',
        createdAt: DateTime(2025, 1, 18).toSecondsSinceEpoch(),
        tags: const [
          [TagValue.e, _targetPostId],
          [TagValue.a, aTag],
        ],
      );

      await rawEventStore.upsert([deletionEvent]);

      // Both should be deleted
      final postAfter = await rawEventStore.queryEvents(
        const RawEventQuery(ids: [_targetPostId]),
      );
      expect(postAfter, isEmpty);

      final listingAfter = await rawEventStore.queryEvents(
        const RawEventQuery(ids: ['listing_event_003']),
      );
      expect(listingAfter, isEmpty);
    });

    test(
      'kind=5 with no e-tags and no a-tags does not delete anything',
      () async {
        final postEvent = NostrEvent(
          id: _targetPostId,
          pubkey: _authorPubkey,
          kind: 1,
          content: 'Hello',
          sig: 'deadbeef',
          createdAt: DateTime(2025, 1, 17).toSecondsSinceEpoch(),
          tags: const [],
        );

        await rawEventStore.upsert([postEvent]);

        final deletionEvent = NostrEvent(
          id: 'deletion_event_004',
          pubkey: _authorPubkey,
          kind: NostrKind.deletion,
          content: '',
          sig: 'deadbeef',
          createdAt: DateTime(2025, 1, 18).toSecondsSinceEpoch(),
          tags: const [],
        );

        await rawEventStore.upsert([deletionEvent]);

        final after = await rawEventStore.queryEvents(
          const RawEventQuery(ids: [_targetPostId]),
        );
        expect(after, hasLength(1));
      },
    );
  });
}
