import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:di_storage/di_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:common/services/event_store/database/app_database.dart';
import 'package:common/services/event_store/database/daos/outbox_dao_interface.dart';
import 'package:common/services/event_store/database/tables/outbox_events.dart';
import 'package:common/services/event_store/raw_event_store.dart';
import 'package:nostr/model/nostr_event.dart';
import 'package:nostr/nostr_client/channel_factory.dart';
import 'package:nostr_notes/services/outbox_publisher.dart';
import 'package:nostr/nostr_client/ws_channel.dart';
import 'package:rxdart/rxdart.dart';

import '../../../notes/test/tools/mock_wschannel.dart';
import '../../../notes/test/tools/mocks/mock_relays_list_repo.dart';
import '../tools/di/in_memory_db_module.dart';

void main() {
  group('OutboxPublisher', () {
    late AppDatabase db;
    late _MockOutboxDao mockOutboxDao;
    late RawEventStore mockRawEventStore;
    late MockRelaysListRepo mockRelaysListRepo;
    late _MockChannelFactory mockChannelFactory;
    late _MockConnectivity mockConnectivity;
    late OutboxPublisher sut;

    setUp(() {
      final di = DiStorage.shared;
      di.removeAll();
      const InMemoryDbModule().bind(DiStorage.shared);
      db = di.resolve();

      mockOutboxDao = _MockOutboxDao();
      mockRawEventStore = di.resolve();
      mockRelaysListRepo = MockRelaysListRepo.withRelays({'wss://relay.test'});
      mockChannelFactory = _MockChannelFactory();
      mockConnectivity = _MockConnectivity();

      sut = OutboxPublisher(
        outboxDao: mockOutboxDao,
        rawEventStore: mockRawEventStore,
        relaysListRepo: mockRelaysListRepo,
        channelFactory: mockChannelFactory,
        connectivity: mockConnectivity,
        connectivityDebounce: Duration.zero,
      );
    });

    tearDown(() async {
      await sut.dispose();
      mockOutboxDao.dispose();
      DiStorage.shared.removeAll();
      await db.close();
    });

    group('init', () {
      test('subscribes to pending events stream', () async {
        await sut.init();

        expect(mockOutboxDao.watchUndeliveredCalled, isTrue);
      });
    });

    group('dispose', () {
      test('cancels subscription without error', () async {
        await sut.init();
        await sut.dispose();
      });
    });

    group('pause/resume', () {
      test('pause stops processing', () async {
        await sut.init();
        sut.pause();

        mockOutboxDao.addPendingEvent(_createOutboxEvent('event1'));
        await Future.delayed(const Duration(milliseconds: 50));

        expect(mockOutboxDao.markBroadcastingCalledWith, isEmpty);
      });

      test('resume triggers processing of pending events', () async {
        mockChannelFactory.respondWithOk = true;
        mockRawEventStore.upsert([_createTestEvent('event1')]);

        await sut.init();
        sut.pause();

        mockOutboxDao.addPendingEvent(_createOutboxEvent('event1'));
        await Future.delayed(const Duration(milliseconds: 50));

        sut.resume();
        await Future.delayed(const Duration(milliseconds: 100));

        expect(mockOutboxDao.markBroadcastingCalledWith, contains('event1'));
      });
    });

    group('publishing', () {
      test('marks event as broadcasting before publishing', () async {
        mockChannelFactory.respondWithOk = true;
        mockRawEventStore.upsert([_createTestEvent('event1')]);

        await sut.init();
        mockOutboxDao.addPendingEvent(_createOutboxEvent('event1'));

        await Future.delayed(const Duration(milliseconds: 100));

        expect(mockOutboxDao.markBroadcastingCalledWith, contains('event1'));
      });

      test('marks event as sent on successful publish', () async {
        mockChannelFactory.respondWithOk = true;
        mockRawEventStore.upsert([_createTestEvent('event1')]);

        await sut.init();
        mockOutboxDao.addPendingEvent(_createOutboxEvent('event1'));

        await Future.delayed(const Duration(milliseconds: 100));

        expect(mockOutboxDao.markSentCalledWith, contains('event1'));
      });

      test('marks event as failed when event not found in store', () async {
        await sut.init();
        mockOutboxDao.addPendingEvent(_createOutboxEvent('missing'));

        await Future.delayed(const Duration(milliseconds: 100));

        expect(mockOutboxDao.markFailedCalledWith, contains('missing'));
      });

      test('marks event as failed when no relays configured', () async {
        await mockRelaysListRepo.clear();
        mockRawEventStore.upsert([_createTestEvent('event1')]);

        await sut.init();
        mockOutboxDao.addPendingEvent(_createOutboxEvent('event1'));

        await Future.delayed(const Duration(milliseconds: 100));

        expect(mockOutboxDao.markFailedCalledWith, contains('event1'));
      });

      test('retries on publish failure (all relays reject)', () async {
        mockChannelFactory.respondWithOk = false;
        mockChannelFactory.respondWithFail = true;
        mockRawEventStore.upsert([_createTestEvent('event1')]);

        await sut.init();
        mockOutboxDao.addPendingEvent(_createOutboxEvent('event1'));

        await Future.delayed(const Duration(milliseconds: 100));

        expect(mockOutboxDao.retryFailedCalledWith, contains('event1'));
      });

      test('retries indefinitely regardless of attempt count', () async {
        mockChannelFactory.respondWithOk = false;
        mockChannelFactory.respondWithFail = true;
        mockRawEventStore.upsert([_createTestEvent('event1')]);

        await sut.init();
        // Even with high attemptCount, event should still be retried (not permanently failed)
        mockOutboxDao.addPendingEvent(
          _createOutboxEvent('event1', attemptCount: 99),
        );

        await Future.delayed(const Duration(milliseconds: 100));

        expect(mockOutboxDao.retryFailedCalledWith, contains('event1'));
        expect(mockOutboxDao.markFailedCalledWith, isNot(contains('event1')));
      });
    });

    group('connectivity', () {
      test('resumes processing when network changes', () async {
        mockChannelFactory.respondWithOk = true;
        mockRawEventStore.upsert([_createTestEvent('event1')]);

        await sut.init();
        sut.pause();

        mockOutboxDao.addPendingEvent(_createOutboxEvent('event1'));
        await Future.delayed(const Duration(milliseconds: 50));
        expect(mockOutboxDao.markBroadcastingCalledWith, isEmpty);

        // Simulate network change — triggers pause()+resume() in _onConnectivityChanged
        mockConnectivity.setConnectivity([ConnectivityResult.wifi]);
        // debounceTime(2s) is bypassed in mock (no debounce), so just wait for processing
        await Future.delayed(const Duration(milliseconds: 100));

        expect(mockOutboxDao.markBroadcastingCalledWith, contains('event1'));
      });
    });

    group('retryAllFailed', () {
      test('calls dao retryAllFailed', () async {
        await sut.init();
        await sut.retryAllFailed();

        expect(mockOutboxDao.retryAllFailedCalled, isTrue);
      });
    });

    group('cleanup', () {
      test('delegates to dao cleanupOldSent', () async {
        final result = await sut.cleanup();

        expect(result, 0);
        expect(mockOutboxDao.cleanupOldSentCalled, isTrue);
      });
    });
  });

  group('NoopOutboxPublisher', () {
    test('init and dispose do not throw', () async {
      final noop = NoopOutboxPublisher();
      await noop.init();
      await noop.dispose();
    });

    test('pause and resume do not throw', () {
      final noop = NoopOutboxPublisher();
      noop.pause();
      noop.resume();
    });

    test('cleanup returns 0', () async {
      final noop = NoopOutboxPublisher();
      expect(await noop.cleanup(), 0);
    });
  });

  group('Real OutboxDaoInterface', () {
    late AppDatabase db;
    late OutboxDaoInterface dao;

    setUp(() {
      final di = DiStorage.shared;
      di.removeAll();
      const InMemoryDbModule().bind(di);
      db = di.resolve();
      dao = di.resolve<OutboxDaoInterface>();
    });

    tearDown(() async {
      await db.close();
      DiStorage.shared.removeAll();
    });

    test('insert then getPending returns the event', () async {
      await dao.insert(eventId: 'event1');

      final pending = await dao.getPending();
      expect(pending.length, 1);
      expect(pending.first.eventId, 'event1');
      expect(pending.first.status, OutboxStatus.pending);
    });

    test('markBroadcasting → markSent full lifecycle', () async {
      await dao.insert(eventId: 'event2');
      await dao.markBroadcasting('event2');

      final pending = await dao.getPending();
      expect(pending, isEmpty);

      await dao.markSent('event2', confirmedRelays: ['wss://relay.test']);

      final failed = await dao.getFailed();
      expect(failed, isEmpty);

      // sent events are not returned by getPending or getFailed
      final stillPending = await dao.getPending();
      expect(stillPending, isEmpty);
    });

    test('markFailed then retryFailed increments attemptCount', () async {
      await dao.insert(eventId: 'event3');
      await dao.markFailed('event3', 'no relays');

      final failed = await dao.getFailed();
      expect(failed.length, 1);
      expect(failed.first.status, OutboxStatus.failed);

      await dao.retryFailed('event3');

      final pending = await dao.getPending();
      expect(pending.length, 1);
      expect(pending.first.eventId, 'event3');
      expect(pending.first.attemptCount, 1);
      expect(pending.first.status, OutboxStatus.pending);
    });

    test('cleanupOldSent removes sent events older than threshold', () async {
      await dao.insert(eventId: 'old_event');
      await dao.markBroadcasting('old_event');
      await dao.markSent('old_event');

      // cleanup with 0 duration — removes all sent events
      final removed = await dao.cleanupOldSent(olderThan: Duration.zero);
      expect(removed, 1);
    });
  });
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

OutboxEventData _createOutboxEvent(String eventId, {int attemptCount = 0}) {
  return OutboxEventData(
    eventId: eventId,
    status: OutboxStatus.pending,
    attemptCount: attemptCount,
    createdAt: DateTime.now().millisecondsSinceEpoch,
    lastAttemptAt: null,
    confirmedRelays: null,
    failureReason: null,
  );
}

NostrEvent _createTestEvent(String id) {
  return NostrEvent(
    id: id,
    pubkey: 'test-pubkey',
    createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    kind: 30023,
    tags: const [],
    content: 'test content',
    sig: 'test-sig',
  );
}

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

/// Mock [ChannelFactory] returning [MockWSChannel] with configurable
/// auto-response behaviour for OK / fail.
class _MockChannelFactory implements ChannelFactory {
  bool respondWithOk = true;
  bool respondWithFail = false;

  final channels = <MockWSChannel>[];

  @override
  WsChannel create(String url) {
    final mock = MockWSChannel(url: url);

    if (respondWithOk || respondWithFail) {
      mock.onAdd = (data, channel) {
        if (data is! String) return;
        try {
          final decoded = jsonDecode(data) as List;
          if (decoded.isNotEmpty && decoded[0] == 'EVENT') {
            final event = decoded[1] as Map<String, dynamic>;
            final eventId = event['id'] as String;
            final ok = respondWithOk;
            final response = jsonEncode([
              'OK',
              eventId,
              ok,
              ok ? '' : 'test rejection',
            ]);
            channel.mockStream.add(response);
          }
        } catch (_) {}
      };
    }

    channels.add(mock);
    return mock;
  }
}

class _MockOutboxDao implements OutboxDaoInterface {
  bool watchUndeliveredCalled = false;
  List<String> markBroadcastingCalledWith = [];
  List<String> markSentCalledWith = [];
  List<String> markFailedCalledWith = [];
  List<String> retryFailedCalledWith = [];
  bool retryAllFailedCalled = false;
  bool cleanupOldSentCalled = false;

  final _pendingController = BehaviorSubject<List<OutboxEventData>>.seeded([]);
  List<OutboxEventData> pendingAfterRetry = [];

  @override
  Future<void> insert({required String eventId}) async {
    addPendingEvent(_createOutboxEvent(eventId));
  }

  @override
  Stream<List<OutboxEventData>> watchPending() {
    return _pendingController.stream;
  }

  void addPendingEvent(OutboxEventData event) {
    final current = List<OutboxEventData>.from(_pendingController.value);
    current.add(event);
    _pendingController.add(current);
  }

  @override
  Future<List<OutboxEventData>> getPending() async => _pendingController.value;

  @override
  Future<void> markBroadcasting(String eventId) async {
    markBroadcastingCalledWith.add(eventId);
  }

  @override
  Future<void> markSent(String eventId, {List<String>? confirmedRelays}) async {
    markSentCalledWith.add(eventId);
    final current = List<OutboxEventData>.from(_pendingController.value);
    current.removeWhere((e) => e.eventId == eventId);
    _pendingController.add(current);
  }

  @override
  Future<void> markFailed(String eventId, String reason) async {
    markFailedCalledWith.add(eventId);
    final current = List<OutboxEventData>.from(_pendingController.value);
    current.removeWhere((e) => e.eventId == eventId);
    _pendingController.add(current);
  }

  @override
  Future<void> retryFailed(String eventId) async {
    retryFailedCalledWith.add(eventId);
  }

  @override
  Future<List<OutboxEventData>> getFailed() async => [];

  @override
  Future<void> retryAllFailed() async {
    retryAllFailedCalled = true;
    if (pendingAfterRetry.isNotEmpty) {
      _pendingController.add(pendingAfterRetry);
    }
  }

  @override
  Future<void> deleteSent(String eventId) async {}

  @override
  Future<int> cleanupOldSent({
    Duration olderThan = const Duration(days: 7),
  }) async {
    cleanupOldSentCalled = true;
    return 0;
  }

  void dispose() {
    _pendingController.close();
  }

  @override
  Future<void> removeUndeliveredByEventIds(Set<String> eventIds) async {
    final current = List<OutboxEventData>.from(_pendingController.value);
    current.removeWhere((e) => eventIds.contains(e.eventId));
    _pendingController.add(current);
  }

  @override
  Stream<List<OutboxEventData>> watchUndelivered() {
    watchUndeliveredCalled = true;
    return _pendingController.stream;
  }
}

class _MockConnectivity implements Connectivity {
  final _controller = StreamController<List<ConnectivityResult>>.broadcast();
  List<ConnectivityResult> _currentResult = [ConnectivityResult.wifi];

  void setConnectivity(List<ConnectivityResult> results) {
    _currentResult = results;
    _controller.add(results);
  }

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => _currentResult;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _controller.stream;
}
