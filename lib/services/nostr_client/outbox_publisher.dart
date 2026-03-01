import 'dart:async';
import 'dart:developer' as dev;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:nostr_notes/auth/domain/repo/relays_list_repo.dart';
import 'package:nostr_notes/core/event_kind.dart';
import 'package:nostr_notes/core/tools/disposable.dart';
import 'package:nostr_notes/services/event_store/database/app_database.dart';
import 'package:nostr_notes/services/event_store/database/daos/outbox_dao_interface.dart';
import 'package:nostr_notes/services/event_store/raw_event_store.dart';
import 'package:nostr_notes/services/nostr_client/channel_factory.dart';
import 'package:nostr_notes/services/nostr_client/nostr_client.dart';
import 'package:nostr_notes/services/nostr_client/nostr_publisher.dart';
import 'package:nostr_notes/services/nostr_client/publish_event_report.dart';

/// Watches the outbox table and publishes pending events to Nostr relays.
///
/// This is the "Nostr Adapter" layer that handles outbound sync from SQL to relays.
/// The app core writes to SQL + outbox, and this service handles the async
/// publishing in the background.
class OutboxPublisher implements Disposable {
  OutboxPublisher({
    required OutboxDaoInterface outboxDao,
    required RawEventStore rawEventStore,
    required RelaysListRepo relaysListRepo,
    required ChannelFactory channelFactory,
    Connectivity? connectivity,
  }) : _outboxDao = outboxDao,
       _rawEventStore = rawEventStore,
       _relaysListRepo = relaysListRepo,
       _channelFactory = channelFactory,
       _connectivity = connectivity ?? Connectivity();

  final OutboxDaoInterface _outboxDao;
  final RawEventStore _rawEventStore;
  final RelaysListRepo _relaysListRepo;
  final ChannelFactory _channelFactory;
  final Connectivity _connectivity;

  StreamSubscription<List<OutboxEventData>>? _subscription;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isProcessing = false;
  bool _isPaused = false;
  bool _isDisposing = false;
  bool _isOffline = false;

  static const _maxRetries = 5;
  static const _retryDelays = [
    Duration(seconds: 5),
    Duration(seconds: 30),
    Duration(minutes: 2),
    Duration(minutes: 10),
    Duration(minutes: 30),
  ];

  Future<void> init() async {
    // Cancel existing subscriptions to prevent memory leak on app resume
    await _subscription?.cancel();
    await _connectivitySubscription?.cancel();
    _isDisposing = false;

    // Check initial connectivity
    final connectivityResult = await _connectivity.checkConnectivity();
    _isOffline = connectivityResult.every((r) => r == ConnectivityResult.none);

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _onConnectivityChanged,
    );

    _subscription = _outboxDao.watchPending().listen(_onPendingEvents);
    dev.log(
      'OutboxPublisher initialized (offline: $_isOffline)',
      name: 'OutboxPublisher',
    );
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final nowOffline = results.every((r) => r == ConnectivityResult.none);

    if (nowOffline && !_isOffline) {
      _isOffline = true;
      dev.log('Network lost, pausing outbox', name: 'OutboxPublisher');
    } else if (!nowOffline && _isOffline) {
      _isOffline = false;
      dev.log('Network restored, processing outbox', name: 'OutboxPublisher');
      _processQueue();
    }
  }

  @override
  Future<void> dispose() async {
    _isDisposing = true;

    // Wait for any in-flight operations to complete (with timeout)
    final timeout = DateTime.now().add(const Duration(seconds: 5));
    while (_isProcessing && DateTime.now().isBefore(timeout)) {
      await Future.delayed(const Duration(milliseconds: 50));
    }

    if (_isProcessing) {
      dev.log(
        'Warning: Disposed while still processing',
        name: 'OutboxPublisher',
      );
    }

    await _subscription?.cancel();
    _subscription = null;
    await _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    dev.log('OutboxPublisher disposed', name: 'OutboxPublisher');
  }

  void pause() {
    _isPaused = true;
    _subscription?.pause();
    dev.log('OutboxPublisher paused', name: 'OutboxPublisher');
  }

  void resume() {
    _isPaused = false;
    _subscription?.resume();
    // Process any pending events that accumulated while paused
    _processQueue();
    dev.log('OutboxPublisher resumed', name: 'OutboxPublisher');
  }

  void _onPendingEvents(List<OutboxEventData> pending) {
    if (pending.isEmpty || _isProcessing || _isPaused) return;
    _processQueue();
  }

  Future<void> _processQueue() async {
    if (_isProcessing || _isPaused || _isDisposing || _isOffline) return;
    _isProcessing = true;

    try {
      final pending = await _outboxDao.getPending();

      for (final item in pending) {
        if (_isDisposing || _isPaused || _isOffline) break;

        try {
          await _publishEvent(item);
        } catch (e, stackTrace) {
          dev.log(
            'Exception processing ${item.eventId}: $e\n$stackTrace',
            name: 'OutboxPublisher',
            error: e,
            stackTrace: stackTrace,
          );
        }
      }
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> _publishEvent(OutboxEventData item) async {
    try {
      await _outboxDao.markBroadcasting(item.eventId);

      final events = await _rawEventStore.queryEvents(
        RawEventQuery(ids: [item.eventId]),
      );

      if (events.isEmpty) {
        await _outboxDao.markFailed(item.eventId, 'Event not found in store');
        dev.log(
          'Event ${item.eventId} not found in store',
          name: 'OutboxPublisher',
        );
        return;
      }

      final event = events.first;
      final relays = _relaysListRepo.getRelaysList();

      if (relays.isEmpty) {
        await _outboxDao.markFailed(item.eventId, 'No relays configured');
        dev.log(
          'No relays configured for ${item.eventId}',
          name: 'OutboxPublisher',
        );
        return;
      }

      final client = NostrClient(channelFactory: _channelFactory);
      try {
        client.addRelays(relays);

        final publisher = NostrPublisher(client: client, event: event);
        final report = await publisher.execute();

        if (report.error is NotPublished) {
          await _handleFailure(item, report.error.toString());
        } else {
          final confirmedRelays = report.events.map((e) => e.relay).toList();
          await _outboxDao.markSent(
            item.eventId,
            confirmedRelays: confirmedRelays,
          );
          final kindName = _getKindName(event.kind);
          dev.log(
            'Published ${item.eventId} ($kindName) to ${confirmedRelays.length} relays',
            name: 'OutboxPublisher',
          );
        }
      } finally {
        await client.disconnectAndDispose();
      }
    } catch (e) {
      await _handleFailure(item, e.toString());
      rethrow;
    }
  }

  Future<void> _handleFailure(OutboxEventData item, String reason) async {
    final attempts = item.attemptCount + 1;
    dev.log(
      'Failed to publish ${item.eventId} (attempt $attempts): $reason',
      name: 'OutboxPublisher',
    );

    if (attempts >= _maxRetries) {
      await _outboxDao.markFailed(item.eventId, reason);
    } else {
      await _outboxDao.retryFailed(item.eventId);

      final delay = _retryDelays[attempts - 1];
      Future.delayed(delay, _processQueue);
    }
  }

  /// Manually retry all failed events
  Future<void> retryAllFailed() async {
    await _outboxDao.retryAllFailed();
    _processQueue();
  }

  /// Clean up old sent events
  Future<int> cleanup({Duration olderThan = const Duration(days: 7)}) async {
    return _outboxDao.cleanupOldSent(olderThan: olderThan);
  }

  String _getKindName(int kind) {
    if (kind == EventKind.note.value) return 'note';
    if (kind == NostrKind.deletion) return 'deletion';
    return 'kind $kind';
  }
}

/// No-op implementation for testing
class NoopOutboxPublisher implements Disposable {
  const NoopOutboxPublisher();

  Future<void> init() async {}

  @override
  Future<void> dispose() async {}

  void pause() {}

  void resume() {}

  Future<void> retryAllFailed() async {}

  Future<int> cleanup({Duration olderThan = const Duration(days: 7)}) async {
    return 0;
  }
}
