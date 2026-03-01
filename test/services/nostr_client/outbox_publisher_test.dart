import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_notes/services/event_store/database/app_database.dart';
import 'package:nostr_notes/services/event_store/database/daos/outbox_dao_interface.dart';
import 'package:nostr_notes/services/event_store/database/tables/outbox_events.dart';
import 'package:nostr_notes/services/event_store/raw_event_store.dart';
import 'package:nostr_notes/services/model/nostr_event.dart';
import 'package:nostr_notes/services/nostr_client/channel_factory.dart';
import 'package:nostr_notes/services/nostr_client/outbox_publisher.dart';
import 'package:nostr_notes/services/nostr_client/ws_channel.dart';
import 'package:rxdart/rxdart.dart';

import '../../tools/mock_wschannel.dart';
import '../../tools/mocks/mock_relays_list_repo.dart';

void main() {
  group('OutboxPublisher', () {
    late _MockOutboxDao mockOutboxDao;
    late _MockRawEventStore mockRawEventStore;
    late MockRelaysListRepo mockRelaysListRepo;
    late _MockChannelFactory mockChannelFactory;
    late _MockConnectivity mockConnectivity;
    late OutboxPublisher sut;

    setUp(() {
      mockOutboxDao = _MockOutboxDao();
      mockRawEventStore = _MockRawEventStore();
      mockRelaysListRepo = MockRelaysListRepo.withRelays({'wss://relay.test'});
      mockChannelFactory = _MockChannelFactory();
      mockConnectivity = _MockConnectivity();

      sut = OutboxPublisher(
        outboxDao: mockOutboxDao,
        rawEventStore: mockRawEventStore,
        relaysListRepo: mockRelaysListRepo,
        channelFactory: mockChannelFactory,
        connectivity: mockConnectivity,
      );
    });

    tearDown(() async {
      await sut.dispose();
      mockOutboxDao.dispose();
    });

    group('init', () {
      test('subscribes to pending events stream', () async {
        await sut.init();

        expect(mockOutboxDao.watchPendingCalled, isTrue);
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
        mockRawEventStore.eventsToReturn = [_createTestEvent('event1')];

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
        mockRawEventStore.eventsToReturn = [_createTestEvent('event1')];

        await sut.init();
        mockOutboxDao.addPendingEvent(_createOutboxEvent('event1'));

        await Future.delayed(const Duration(milliseconds: 100));

        expect(mockOutboxDao.markBroadcastingCalledWith, contains('event1'));
      });

      test('marks event as sent on successful publish', () async {
        mockChannelFactory.respondWithOk = true;
        mockRawEventStore.eventsToReturn = [_createTestEvent('event1')];

        await sut.init();
        mockOutboxDao.addPendingEvent(_createOutboxEvent('event1'));

        await Future.delayed(const Duration(milliseconds: 100));

        expect(mockOutboxDao.markSentCalledWith, contains('event1'));
      });

      test('marks event as failed when event not found in store', () async {
        mockRawEventStore.eventsToReturn = [];

        await sut.init();
        mockOutboxDao.addPendingEvent(_createOutboxEvent('missing'));

        await Future.delayed(const Duration(milliseconds: 100));

        expect(mockOutboxDao.markFailedCalledWith, contains('missing'));
      });

      test('marks event as failed when no relays configured', () async {
        await mockRelaysListRepo.clear();
        mockRawEventStore.eventsToReturn = [_createTestEvent('event1')];

        await sut.init();
        mockOutboxDao.addPendingEvent(_createOutboxEvent('event1'));

        await Future.delayed(const Duration(milliseconds: 100));

        expect(mockOutboxDao.markFailedCalledWith, contains('event1'));
      });

      test('retries on publish failure (all relays reject)', () async {
        mockChannelFactory.respondWithOk = false;
        mockChannelFactory.respondWithFail = true;
        mockRawEventStore.eventsToReturn = [_createTestEvent('event1')];

        await sut.init();
        mockOutboxDao.addPendingEvent(_createOutboxEvent('event1'));

        await Future.delayed(const Duration(milliseconds: 100));

        expect(mockOutboxDao.retryFailedCalledWith, contains('event1'));
      });

      test('marks as permanently failed after max retries', () async {
        mockChannelFactory.respondWithOk = false;
        mockChannelFactory.respondWithFail = true;
        mockRawEventStore.eventsToReturn = [_createTestEvent('event1')];

        await sut.init();
        // attemptCount = 4, next failure makes attempt #5 = max
        mockOutboxDao.addPendingEvent(
          _createOutboxEvent('event1', attemptCount: 4),
        );

        await Future.delayed(const Duration(milliseconds: 100));

        expect(mockOutboxDao.markFailedCalledWith, contains('event1'));
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
      const noop = NoopOutboxPublisher();
      await noop.init();
      await noop.dispose();
    });

    test('pause and resume do not throw', () {
      const noop = NoopOutboxPublisher();
      noop.pause();
      noop.resume();
    });

    test('cleanup returns 0', () async {
      const noop = NoopOutboxPublisher();
      expect(await noop.cleanup(), 0);
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

class _MockRawEventStore implements RawEventStore {
  List<NostrEvent> eventsToReturn = [];

  @override
  Future<List<NostrEvent>> queryEvents(RawEventQuery query) async {
    if (query.ids != null && query.ids!.isNotEmpty) {
      return eventsToReturn.where((e) => query.ids!.contains(e.id)).toList();
    }
    return eventsToReturn;
  }

  @override
  Future<void> upsert(Iterable<NostrEvent> events, {String? relayUrl}) async {}

  @override
  Stream<List<NostrEvent>> watchEvents(RawEventQuery query) =>
      Stream.value(eventsToReturn);

  @override
  Future<Set<String>> filterMissingEventIds(Set<String> ids) async => {};

  @override
  Future<Set<String>> filterMissingPubkeys(Set<String> pubkeys) async => {};

  @override
  Future<Set<String>> filterMissingDTags(Set<String> dTags) async => {};

  @override
  Future<void> deleteEvents(Set<String> ids) async {}
}

class _MockOutboxDao implements OutboxDaoInterface {
  bool watchPendingCalled = false;
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
    watchPendingCalled = true;
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
