import 'dart:async';
import 'dart:developer' as dev;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:nostr/nostr_client/channel_factory.dart';
import 'package:nostr/nostr_client/nostr_client.dart';
import 'package:nostr/nostr_client/nostr_publisher.dart';
import 'package:common/domain/repo/relays_list_repo.dart';
import 'package:nostr_notes/core/event_kind.dart';
import 'package:common/tools/disposable.dart';
import 'package:common/services/event_store/database/app_database.dart';
import 'package:common/services/event_store/database/daos/outbox_dao_interface.dart';
import 'package:common/services/event_store/raw_event_store.dart';
import 'package:rxdart/rxdart.dart';

/// Watches the outbox table and publishes its events to Nostr relays.
///
/// This is the "Nostr Adapter" layer that handles outbound sync from SQL to
/// relays. The app core writes to SQL + outbox, and this service publishes in
/// the background.
///
/// The outbox is a plain queue: **a row exists iff the event still needs to
/// reach relays.** On success the row is deleted; on failure it is left in
/// place and retried later. Concurrency within a session is serialized by
/// [_isProcessing], so no per-row "in flight" state is needed.
class OutboxPublisher implements Disposable {
  OutboxPublisher({
    required OutboxDaoInterface outboxDao,
    required RawEventStore rawEventStore,
    required RelaysListRepo relaysListRepo,
    required ChannelFactory channelFactory,
    required Connectivity connectivity,
    this.connectivityDebounce = const Duration(seconds: 2),
  }) : _outboxDao = outboxDao,
       _rawEventStore = rawEventStore,
       _relaysListRepo = relaysListRepo,
       _channelFactory = channelFactory,
       _connectivity = connectivity;

  final OutboxDaoInterface _outboxDao;
  final RawEventStore _rawEventStore;
  final RelaysListRepo _relaysListRepo;
  final ChannelFactory _channelFactory;
  final Connectivity _connectivity;
  final Duration connectivityDebounce;

  StreamSubscription<List<OutboxEventData>>? _subscription;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _retryTimer;
  bool _isProcessing = false;
  bool _isPaused = false;
  bool _isDisposing = false;
  bool _refreshRequested = false;

  static const _retryDelay = Duration(seconds: 20);

  Future<void> init() async {
    // Cancel existing subscriptions to prevent memory leak on app resume
    await _subscription?.cancel();
    await _connectivitySubscription?.cancel();
    _isDisposing = false;
    _isProcessing = false;

    _connectivitySubscription = _connectivity.onConnectivityChanged
        .debounceTime(connectivityDebounce)
        .listen(_onConnectivityChanged);

    _subscription = _outboxDao.watchUndelivered().listen(_onPendingEvents);
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    refresh();
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
    _retryTimer?.cancel();
    _retryTimer = null;
    dev.log('OutboxPublisher disposed', name: 'OutboxPublisher');
  }

  void refresh() {
    _isPaused = false;
    _subscription?.resume();
    _refreshRequested = true;
    _processQueue();
  }

  void pause() {
    _isPaused = true;
    _subscription?.pause();
    dev.log('OutboxPublisher paused', name: 'OutboxPublisher');
  }

  void resume() {
    _isPaused = false;
    _subscription?.resume();
    // Process any events that accumulated while paused
    _refreshRequested = true;
    _processQueue();
    dev.log('OutboxPublisher resumed', name: 'OutboxPublisher');
  }

  void _onPendingEvents(List<OutboxEventData> pending) {
    if (pending.isEmpty || _isPaused) return;
    if (_isProcessing) {
      _refreshRequested = true;
      return;
    }
    _refreshRequested = true;
    _processQueue();
  }

  Future<void> _processQueue() async {
    if (_isPaused || _isDisposing) return;
    if (_isProcessing) {
      _refreshRequested = true;
      return;
    }
    _isProcessing = true;

    try {
      do {
        _refreshRequested = false;
        final pending = await _outboxDao.getPending();

        for (final item in pending) {
          if (_isDisposing || _isPaused) break;

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
      } while (_refreshRequested && !_isPaused && !_isDisposing);
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> _publishEvent(OutboxEventData item) async {
    try {
      final events = await _rawEventStore.queryEvents(
        RawEventQuery(ids: [item.eventId]),
      );

      if (events.isEmpty) {
        // The referenced event no longer exists; drop the orphaned entry.
        await _outboxDao.remove(item.eventId);
        dev.log(
          'Event ${item.eventId} not found in store, dropped from outbox',
          name: 'OutboxPublisher',
        );
        return;
      }

      final event = events.first;
      final relays = _relaysListRepo.getRelaysList();

      if (relays.isEmpty) {
        // Transient: no relays configured yet. Keep the entry and retry later.
        _scheduleRetry(item, 'No relays configured');
        return;
      }

      final client = NostrClient(channelFactory: _channelFactory);
      try {
        client.addRelays(relays);

        final publisher = NostrPublisher(client: client, event: event);
        final report = await publisher.execute();

        if (!report.isAnySuccess) {
          _scheduleRetry(item, report.error.toString());
        } else {
          // Delivered — remove from the outbox.
          await _outboxDao.remove(item.eventId);
          final confirmed = report.okEvents.where((e) => e.isOk).length;
          dev.log(
            'Published ${item.eventId} (${_getKindName(event.kind)}) '
            'to $confirmed relays',
            name: 'OutboxPublisher',
          );
        }
      } finally {
        await client.disconnectAndDispose();
      }
    } catch (e) {
      _scheduleRetry(item, e.toString());
      rethrow;
    }
  }

  /// Schedule a retry after a publish failure. The outbox row is left in place
  /// (a present row means "still needs delivery"), so no DB write happens here
  /// — that avoids re-triggering the watch stream and looping tightly. Fresh
  /// events retry sooner than old ones.
  void _scheduleRetry(OutboxEventData item, String reason) {
    dev.log(
      'Failed to publish ${item.eventId}: $reason',
      name: 'OutboxPublisher',
    );

    _retryTimer?.cancel();
    final ageMs = DateTime.now().millisecondsSinceEpoch - item.createdAt;
    final delay = ageMs < 5000 ? const Duration(seconds: 3) : _retryDelay;
    _retryTimer = Timer(delay, () {
      dev.log('Retrying outbox after $delay', name: 'OutboxPublisher');
      _processQueue();
    });
  }

  String _getKindName(int kind) {
    if (kind == EventKind.note.value) return 'note';
    if (kind == NostrKind.deletion) return 'deletion';
    return 'kind $kind';
  }
}

/// No-op implementation for testing
class NoopOutboxPublisher implements OutboxPublisher, Disposable {
  @override
  Future<void> init() async {}

  @override
  Future<void> dispose() async {}

  @override
  void refresh() {}

  @override
  void pause() {}

  @override
  void resume() {}

  @override
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  bool _isDisposing = false;

  @override
  bool _isPaused = false;

  @override
  bool _isProcessing = false;

  @override
  bool _refreshRequested = false;

  @override
  StreamSubscription<List<OutboxEventData>>? _subscription;

  @override
  ChannelFactory get _channelFactory => throw UnimplementedError();

  @override
  Connectivity get _connectivity => throw UnimplementedError();

  @override
  String _getKindName(int kind) {
    throw UnimplementedError();
  }

  @override
  void _scheduleRetry(OutboxEventData item, String reason) {}

  @override
  void _onConnectivityChanged(List<ConnectivityResult> results) {}

  @override
  void _onPendingEvents(List<OutboxEventData> pending) {}

  @override
  OutboxDaoInterface get _outboxDao => throw UnimplementedError();

  @override
  Future<void> _processQueue() async {}

  @override
  Future<void> _publishEvent(OutboxEventData item) async {}

  @override
  RawEventStore get _rawEventStore => throw UnimplementedError();

  @override
  RelaysListRepo get _relaysListRepo => throw UnimplementedError();

  @override
  Duration get connectivityDebounce => throw UnimplementedError();

  @override
  Timer? _retryTimer;
}
