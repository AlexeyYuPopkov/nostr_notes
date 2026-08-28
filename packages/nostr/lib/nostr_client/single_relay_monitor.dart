import 'dart:async';
import 'dart:developer';
import 'package:uuid/uuid.dart';

import '../model/nostr_event.dart';
import '../model/nostr_event_close.dart';
import '../model/nostr_event_eose.dart';
import '../model/nostr_filter.dart';
import '../model/nostr_req.dart';
import '../model/relay_health.dart';
import 'channel_factory.dart';
import 'nostr_relay.dart';

/// Probes a single, not-yet-adopted relay URL over its own dedicated
/// connection — used where there's no [NostrClient] with an open connection
/// to piggyback on yet (checking a candidate URL before it's added to the
/// app's relay set). See `RelayMonitorTicker` for probing relays already
/// known to a client.
final class SingleRelayMonitor {
  final Uri url;
  final ChannelFactory channelFactory;
  final Duration interval;
  final Duration timeout;

  SingleRelayMonitor({
    required this.url,
    required this.channelFactory,
    this.interval = const Duration(seconds: 15),
    this.timeout = const Duration(seconds: 3),
  });

  static const _probeReq = NostrReq(
    filters: [NostrFilter(kinds: _probeKinds, limit: 1)],
  );
  static const _probeKinds = [0, 1, 4, 7, 10002];

  Timer? _timer;
  Timer? _timeoutTimer;
  StreamSubscription? _probeSubscription;
  final _controller = StreamController<RelayHealth>.broadcast();
  RelayHealth _lastStatus = RelayHealth.disconnected;

  RelayHealth get lastStatus => _lastStatus;

  Stream<RelayHealth> get status => _controller.stream;

  FutureOr<RelayHealth> get currentStatus async {
    if (_lastStatus == RelayHealth.disconnected) {
      return await status.first;
    } else {
      return _lastStatus;
    }
  }

  void start() {
    _timer?.cancel();
    _probe();
    _timer = Timer.periodic(interval, (_) => _probe());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
    _probeSubscription?.cancel();
    _probeSubscription = null;
  }

  Future<void> dispose() async {
    stop();
    await _controller.close();
  }

  void _probe() {
    _probeSubscription?.cancel();

    final relay = NostrRelay(
      url: url.toString(),
      channelFactory: channelFactory,
    );
    final fetcher = _SingleRelayFetcher(relay: relay);
    bool receivedEvent = false;
    bool completed = false;

    _probeSubscription = fetcher
        .fetch(_probeReq)
        .listen(
          (_) => receivedEvent = true,
          onDone: () {
            if (completed) {
              return;
            }
            completed = true;
            _emit(
              receivedEvent
                  ? RelayHealth.connected
                  : RelayHealth.connectedNoData,
            );
          },
          onError: (e) {
            if (completed) return;
            completed = true;
            log(
              'Relay monitoring probe failed for $url',
              name: 'SingleRelayMonitor',
              error: e,
            );
            _emit(RelayHealth.error);
          },
        );

    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(timeout, () {
      if (!completed) {
        completed = true;
        _probeSubscription?.cancel();
        _probeSubscription = null;
        _emit(RelayHealth.disconnected);
      }
    });
  }

  void _emit(RelayHealth newStatus) {
    if (_controller.isClosed) return;
    _lastStatus = newStatus;
    _controller.add(newStatus);
  }
}

final class _SingleRelayFetcher {
  final NostrRelay relay;
  final Uuid _uuid;

  const _SingleRelayFetcher({required this.relay, Uuid? uuid})
    : _uuid = uuid ?? const Uuid();

  Stream<NostrEvent> fetch(NostrReq req) {
    final controller = StreamController<NostrEvent>();
    final subscriptionId = _uuid.v4();
    StreamSubscription? subscription;

    controller.onListen = () async {
      subscription = relay.eventStream.listen(
        (event) {
          if (controller.isClosed) return;
          if (event is NostrEvent) {
            controller.add(event);
          } else if (event is NostrEventEose &&
              event.subscriptionId == subscriptionId) {
            controller.close();
          }
        },
        onError: (Object e, StackTrace stack) =>
            _failOnce(controller, e, stack),
      );

      try {
        await relay.sendRequest(req, subscriptionId);
      } catch (e, stack) {
        _failOnce(controller, e, stack);
      }
    };

    controller.onCancel = () {
      subscription?.cancel();
      _ignoreTeardownFailure(
        relay.closeRequest(
          NostrEventClose(relay: relay.url, subscriptionId: subscriptionId),
        ),
      );
      _ignoreTeardownFailure(relay.disconnect());
    };

    return controller.stream;
  }

  /// Teardown most often runs *because* the relay went unreachable, so a
  /// failed goodbye is expected and there is no consumer left to tell.
  void _ignoreTeardownFailure(FutureOr<dynamic> teardown) {
    Future.value(teardown).catchError((Object e) {
      log(
        'Ignoring teardown failure for relay: ${relay.url}',
        name: 'SingleRelayMonitor',
        error: e,
      );
    });
  }

  /// A dead socket reports itself twice — the write fails and the inbound
  /// stream errors — in either order. The consumer only needs the first.
  void _failOnce(
    StreamController<NostrEvent> controller,
    Object error,
    StackTrace stackTrace,
  ) {
    if (controller.isClosed) return;
    controller.addError(error, stackTrace);
    controller.close();
  }
}
