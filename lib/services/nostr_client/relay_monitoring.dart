import 'dart:async';
import 'dart:developer';

import 'package:nostr_notes/common/domain/model/relay_health.dart';
import 'package:nostr_notes/services/model/nostr_event.dart';
import 'package:nostr_notes/services/model/nostr_event_close.dart';
import 'package:nostr_notes/services/model/nostr_event_eose.dart';
import 'package:nostr_notes/services/model/nostr_filter.dart';
import 'package:nostr_notes/services/model/nostr_req.dart';
import 'package:nostr_notes/services/nostr_client/channel_factory.dart';
import 'package:nostr_notes/services/nostr_client/nostr_relay.dart';
import 'package:uuid/uuid.dart';

final class RelayMonitoring {
  final Uri url;
  final ChannelFactory channelFactory;
  final Duration interval;
  final Duration timeout;

  RelayMonitoring({
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
              name: 'RelayMonitoring',
              error: e,
            );
            _emit(RelayHealth.error);
          },
        );

    Future.delayed(timeout, () {
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
      subscription = relay.eventStream.listen((event) {
        if (event is NostrEvent) {
          controller.add(event);
        } else if (event is NostrEventEose &&
            event.subscriptionId == subscriptionId) {
          controller.close();
        }
      }, onError: controller.addError);

      try {
        await relay.sendRequest(req, subscriptionId);
      } catch (e) {
        controller.addError(e);
        controller.close();
      }
    };

    controller.onCancel = () {
      subscription?.cancel();
      relay.closeRequest(
        NostrEventClose(relay: relay.url, subscriptionId: subscriptionId),
      );
      relay.disconnect();
    };

    return controller.stream;
  }
}
