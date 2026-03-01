import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_notes/core/tools/date_time_helper.dart';
import 'package:nostr_notes/services/event_store/nostr_filter_to_raw_event_query_mapper.dart';
import 'package:nostr_notes/services/model/nostr_filter.dart';

typedef _SUT = NostrFilterToRawEventQueryMapper;

void main() {
  group('toRawEventQuery', () {
    test('maps kinds, authors, limit, since, until, search', () {
      final since = DateTime(2024, 1, 1).toSecondsSinceEpoch();
      final until = DateTime(2024, 6, 1).toSecondsSinceEpoch();
      final filter = NostrFilter(
        kinds: const [1, 30023],
        authors: const ['pubkey1', 'pubkey2'],
        limit: 50,
        since: since,
        until: until,
        search: 'hello',
      );

      final result = _SUT.toRawEventQuery(filter);

      expect(result.kinds, [1, 30023]);
      expect(result.authors, ['pubkey1', 'pubkey2']);
      expect(result.limit, 50);
      expect(result.since, DateTime.fromMillisecondsSinceEpoch(since * 1000));
      expect(result.until, DateTime.fromMillisecondsSinceEpoch(until * 1000));
      expect(result.search, 'hello');
    });

    test('clearLimit removes limit', () {
      const filter = NostrFilter(limit: 10);

      final result = _SUT.toRawEventQuery(filter, clearLimit: true);

      expect(result.limit, isNull);
    });

    test('maps p, t, e, a tag filters', () {
      const filter = NostrFilter(
        p: ['p1', 'p2'],
        t: ['tag1'],
        e: ['e1'],
        a: ['a1'],
      );

      final result = _SUT.toRawEventQuery(filter);

      expect(result.tagFilters, hasLength(4));
      expect(result.tagFilters![0].tag, 'p');
      expect(result.tagFilters![0].value, ['p1', 'p2']);
      expect(result.tagFilters![1].tag, 't');
      expect(result.tagFilters![1].value, ['tag1']);
      expect(result.tagFilters![2].tag, 'e');
      expect(result.tagFilters![2].value, ['e1']);
      expect(result.tagFilters![3].tag, 'a');
      expect(result.tagFilters![3].value, ['a1']);
    });

    test('returns null tagFilters when no tags', () {
      const filter = NostrFilter(kinds: [1]);

      final result = _SUT.toRawEventQuery(filter);

      expect(result.tagFilters, isNull);
    });

    test('skips empty tag lists', () {
      const filter = NostrFilter(p: [], t: ['tag1'], e: []);

      final result = _SUT.toRawEventQuery(filter);

      expect(result.tagFilters, hasLength(1));
      expect(result.tagFilters![0].tag, 't');
    });

    test('maps additionalFilters and strips # prefix', () {
      const filter = NostrFilter(
        additional: {
          '#d': ['val1'],
          'custom': ['val2'],
        },
      );

      final result = _SUT.toRawEventQuery(filter);

      expect(result.tagFilters, hasLength(2));
      expect(result.tagFilters![0].tag, 'd');
      expect(result.tagFilters![0].value, ['val1']);
      expect(result.tagFilters![1].tag, 'custom');
      expect(result.tagFilters![1].value, ['val2']);
    });
  });

  group('fromVariantFilter', () {
    test('maps kinds, authors, ids, limit, search', () {
      const filter = NostrFilter(
        kinds: [1, 30023],
        authors: ['pubkey1', 'pubkey2'],
        ids: ['id1', 'id2'],
        limit: 50,
        search: 'hello',
      );

      final result = _SUT.toRawEventQuery(filter);

      expect(result.kinds, [1, 30023]);
      expect(result.authors, ['pubkey1', 'pubkey2']);
      expect(result.ids, ['id1', 'id2']);
      expect(result.limit, 50);
      expect(result.search, 'hello');
    });

    test('converts since/until from epoch seconds to DateTime', () {
      final sinceEpoch = DateTime(2024, 1, 1).millisecondsSinceEpoch ~/ 1000;
      final untilEpoch = DateTime(2024, 6, 1).millisecondsSinceEpoch ~/ 1000;
      final filter = NostrFilter(since: sinceEpoch, until: untilEpoch);

      final result = _SUT.toRawEventQuery(filter);

      expect(result.since, DateTime(2024, 1, 1));
      expect(result.until, DateTime(2024, 6, 1));
    });

    test('since/until are null when not provided', () {
      const filter = NostrFilter();

      final result = _SUT.toRawEventQuery(filter);

      expect(result.since, isNull);
      expect(result.until, isNull);
    });

    test('clearLimit removes limit', () {
      const filter = NostrFilter(limit: 10);

      final result = _SUT.toRawEventQuery(filter, clearLimit: true);

      expect(result.limit, isNull);
    });

    test('maps p, t, e, a, d tag filters', () {
      const filter = NostrFilter(
        p: ['p1', 'p2'],
        t: ['tag1'],
        e: ['e1'],
        a: ['a1'],
        d: ['d1'],
      );

      final result = _SUT.toRawEventQuery(filter);

      expect(result.tagFilters, hasLength(5));
      expect(result.tagFilters![0].tag, 'p');
      expect(result.tagFilters![0].value, ['p1', 'p2']);
      expect(result.tagFilters![1].tag, 't');
      expect(result.tagFilters![1].value, ['tag1']);
      expect(result.tagFilters![2].tag, 'e');
      expect(result.tagFilters![2].value, ['e1']);
      expect(result.tagFilters![3].tag, 'a');
      expect(result.tagFilters![3].value, ['a1']);
      expect(result.tagFilters![4].tag, 'd');
      expect(result.tagFilters![4].value, ['d1']);
    });

    test('returns null tagFilters when no tags', () {
      const filter = NostrFilter(kinds: [1]);

      final result = _SUT.toRawEventQuery(filter);

      expect(result.tagFilters, isNull);
    });

    test('skips empty tag lists', () {
      const filter = NostrFilter(p: [], t: ['tag1'], e: [], d: []);

      final result = _SUT.toRawEventQuery(filter);

      expect(result.tagFilters, hasLength(1));
      expect(result.tagFilters![0].tag, 't');
    });

    test('maps additional filters and strips # prefix', () {
      const filter = NostrFilter(
        additional: {
          '#x': ['val1'],
          'custom': ['val2'],
        },
      );

      final result = _SUT.toRawEventQuery(filter);

      expect(result.tagFilters, hasLength(2));
      expect(result.tagFilters![0].tag, 'x');
      expect(result.tagFilters![0].value, ['val1']);
      expect(result.tagFilters![1].tag, 'custom');
      expect(result.tagFilters![1].value, ['val2']);
    });

    test('maps all fields together', () {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final filter = NostrFilter(
        ids: const ['id1'],
        kinds: const [1985, 10008],
        authors: const ['author1'],
        p: const ['p1'],
        t: const ['t1'],
        since: now,
        until: now,
        limit: 100,
        search: 'test',
      );

      final result = _SUT.toRawEventQuery(filter);

      expect(result.ids, ['id1']);
      expect(result.kinds, [1985, 10008]);
      expect(result.authors, ['author1']);
      expect(result.limit, 100);
      expect(result.search, 'test');
      expect(result.since, isNotNull);
      expect(result.until, isNotNull);
      expect(result.tagFilters, hasLength(2));
    });
  });
}
