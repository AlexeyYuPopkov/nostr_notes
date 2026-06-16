import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:di_storage/di_storage.dart';
import 'package:drift/drift.dart' show Value;
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
      test('subscribes to the undelivered events stream', () async {
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

        // Nothing was published while paused.
        expect(mockChannelFactory.channels, isEmpty);
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

        expect(mockOutboxDao.removeCalledWith, contains('event1'));
      });
    });

    group('publishing', () {
      test('removes event from outbox on successful publish', () async {
        mockChannelFactory.respondWithOk = true;
        mockRawEventStore.upsert([_createTestEvent('event1')]);

        await sut.init();
        mockOutboxDao.addPendingEvent(_createOutboxEvent('event1'));

        await Future.delayed(const Duration(milliseconds: 100));

        expect(mockOutboxDao.removeCalledWith, contains('event1'));
      });

      test('drops orphaned entry when event not found in store', () async {
        await sut.init();
        mockOutboxDao.addPendingEvent(_createOutboxEvent('missing'));

        await Future.delayed(const Duration(milliseconds: 100));

        expect(mockOutboxDao.removeCalledWith, contains('missing'));
        expect(mockChannelFactory.channels, isEmpty);
      });

      test('keeps event (no delivery) when no relays configured', () async {
        await mockRelaysListRepo.clear();
        mockRawEventStore.upsert([_createTestEvent('event1')]);

        await sut.init();
        mockOutboxDao.addPendingEvent(_createOutboxEvent('event1'));

        await Future.delayed(const Duration(milliseconds: 100));

        // Not delivered and not removed — it stays queued for a later retry.
        expect(mockOutboxDao.removeCalledWith, isEmpty);
        expect(mockChannelFactory.channels, isEmpty);
      });

      test('keeps event and retries on publish failure (all relays reject)',
          () async {
        mockChannelFactory.respondWithOk = false;
        mockChannelFactory.respondWithFail = true;
        mockRawEventStore.upsert([_createTestEvent('event1')]);

        await sut.init();
        mockOutboxDao.addPendingEvent(_createOutboxEvent('event1'));

        await Future.delayed(const Duration(milliseconds: 100));
        // First attempt failed: event left in place, nothing removed.
        expect(mockOutboxDao.removeCalledWith, isEmpty);
        expect(mockChannelFactory.channels, isNotEmpty);
        final attemptsAfterFirst = mockChannelFactory.channels.length;

        // Fresh event → retry after 3s; a second publish attempt is made.
        await Future.delayed(const Duration(seconds: 3, milliseconds: 300));
        expect(
          mockChannelFactory.channels.length,
          greaterThan(attemptsAfterFirst),
        );
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
        expect(mockChannelFactory.channels, isEmpty);

        // Network change triggers refresh() in _onConnectivityChanged.
        mockConnectivity.setConnectivity([ConnectivityResult.wifi]);
        await Future.delayed(const Duration(milliseconds: 100));

        expect(mockOutboxDao.removeCalledWith, contains('event1'));
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
    });

    test('remove deletes the event from the outbox', () async {
      await dao.insert(eventId: 'event2');
      await dao.remove('event2');

      expect(await dao.getPending(), isEmpty);
    });

    test('getPending and watchUndelivered exclude legacy sent rows', () async {
      // A row left in `sent` by an older app version must not resurface.
      await db
          .into(db.outboxEvents)
          .insert(
            OutboxEventsCompanion.insert(
              eventId: 'legacy_sent',
              createdAt: DateTime.now().millisecondsSinceEpoch,
              status: const Value(OutboxStatus.sent),
            ),
          );
      await dao.insert(eventId: 'fresh');

      final pending = await dao.getPending();
      expect(pending.map((e) => e.eventId), ['fresh']);

      final undelivered = await dao.watchUndelivered().first;
      expect(undelivered.map((e) => e.eventId), ['fresh']);
    });

    test('removeUndeliveredByEventIds drops queued entries', () async {
      await dao.insert(eventId: 'a');
      await dao.insert(eventId: 'b');

      await dao.removeUndeliveredByEventIds({'a'});

      final pending = await dao.getPending();
      expect(pending.map((e) => e.eventId), ['b']);
    });
  });
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

OutboxEventData _createOutboxEvent(String eventId) {
  return OutboxEventData(
    eventId: eventId,
    status: OutboxStatus.pending,
    attemptCount: 0,
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
  List<String> removeCalledWith = [];

  final _pendingController = BehaviorSubject<List<OutboxEventData>>.seeded([]);

  @override
  Future<void> insert({required String eventId}) async {
    addPendingEvent(_createOutboxEvent(eventId));
  }

  void addPendingEvent(OutboxEventData event) {
    final current = List<OutboxEventData>.from(_pendingController.value);
    current.add(event);
    _pendingController.add(current);
  }

  @override
  Future<List<OutboxEventData>> getPending() async => _pendingController.value;

  @override
  Future<void> remove(String eventId) async {
    removeCalledWith.add(eventId);
    final current = List<OutboxEventData>.from(_pendingController.value);
    current.removeWhere((e) => e.eventId == eventId);
    _pendingController.add(current);
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

  void dispose() {
    _pendingController.close();
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
