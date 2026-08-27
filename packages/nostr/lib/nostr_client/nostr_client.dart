import 'dart:async';
import 'dart:developer';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

import '../model/base_nostr_event.dart';
import '../model/nostr_event.dart';
import '../model/nostr_event_close.dart';
import '../model/nostr_req.dart';
import 'channel_factory.dart';
import 'nostr_client_delegate.dart';
import 'nostr_relay.dart';

final class NostrClient {
  NostrClient({
    ChannelFactory? channelFactory,
    Uuid? uuid,
    EventBatchParser? batchParser,
    this.delegate,
  }) : _channelFactory = channelFactory ?? const ChannelFactory(),
       _uuid = uuid ?? const Uuid(),
       _batchParser = batchParser {
    log('NostrClient - init', name: 'NostrClient');
  }

  final ChannelFactory _channelFactory;
  final Uuid _uuid;
  final EventBatchParser? _batchParser;

  /// Optional observer notified of raw per-relay signals (errors, inbound
  /// activity) as they happen — settable rather than constructor-only so a
  /// delegate that itself composes this client (see `RelaysMonitor`)
  /// can be wired up after both exist, without a construction cycle.
  /// `NostrClient` itself doesn't interpret or aggregate these signals.
  NostrClientDelegate? delegate;

  final _relays = <String, NostrRelay>{};
  Iterable<String> get relays => _relays.values.map((e) => e.url);
  List<String> get relaysList => List.unmodifiable(relays);

  // StreamSubscription? _streamSubscription;
  late final _relaySubject = BehaviorSubject<Set<String>>.seeded({});
  final _relayErrorSubject = PublishSubject<RelayError>();

  /// Stream of non-fatal relay errors (connection failures, timeouts, etc.).
  /// These errors don't interrupt the main event stream.
  Stream<RelayError> get relayErrors => _relayErrorSubject.stream;

  /// The configured relay set, as it changes — e.g. so a delegate can spin
  /// up/tear down per-relay monitoring without polling [relaysList].
  Stream<Set<String>> get relaysListStream => _relaySubject.stream;

  int get count => _relays.length;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  void addRelay(String url) {
    if (!_isValidRelayUrl(url)) return;
    if (!_relays.containsKey(url)) {
      _addRelay(url);
      _relaySubject.add({...?_relaySubject.valueOrNull, url});
    }
  }

  static bool _isValidRelayUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    if (uri.scheme != 'ws' && uri.scheme != 'wss') return false;
    if (uri.hasFragment) return false;
    // Dart normalizes :0 away from Uri for unknown schemes (wss default = 0),
    // so check the raw string for an explicit port of 0.
    if (RegExp(r'://[^/]*:0(/|$)').hasMatch(url)) return false;
    return true;
  }

  NostrRelay? _addRelay(String url) {
    if (!_relays.containsKey(url)) {
      final relay = NostrRelay(
        url: url,
        channelFactory: _channelFactory,
        batchParser: _batchParser,
      );
      // await relay.ready;
      _relays[url] = relay;
      return relay;
    } else {
      return null;
    }
  }

  void addRelays(Iterable<String> urls) async {
    final validUrls = urls.where(_isValidRelayUrl).toList();
    for (final url in validUrls) {
      _addRelay(url);
    }
    _relaySubject.add({...?_relaySubject.valueOrNull, ...validUrls});
  }

  Future<void> removeRelay(String url) async {
    final relay = _relays[url];
    await relay?.disconnect();

    if (relay != null) {
      _relaySubject.add({...?_relaySubject.valueOrNull}..remove(url));
    }
    _relays.remove(url);
  }

  String sendRequestToAll(NostrReq req) {
    final subscriptionId = _uuid.v4();
    for (final relay in _relays.values) {
      _send(relay, () => relay.sendRequest(req, subscriptionId));
    }
    return subscriptionId;
  }

  void sendEventToAll(NostrEvent event) {
    for (final relay in _relays.values) {
      _send(relay, () => relay.sendEvent(event));
    }
  }

  void sendCloseForAll(String subscriptionId) {
    for (final relay in _relays.values) {
      _send(
        relay,
        () => relay.closeRequest(
          NostrEventClose(relay: relay.url, subscriptionId: subscriptionId),
        ),
      );
    }
  }

  void sendClose(String subscriptionId, String relayUrl) {
    for (final relay in _relays.values) {
      if (relay.url == relayUrl) {
        _send(
          relay,
          () => relay.closeRequest(
            NostrEventClose(relay: relay.url, subscriptionId: subscriptionId),
          ),
        );
      }
    }
  }

  /// Fire-and-forget write to a single relay, reporting a failure the same way
  /// an inbound stream error is reported.
  ///
  /// Deliberately not routed through the relay's event stream: [stream]'s
  /// `onErrorResume` would also unsubscribe that relay from the merged stream
  /// until the relay set changes, so a single failed write would cost every
  /// later event from that relay.
  void _send(NostrRelay relay, FutureOr<void> Function() write) {
    Future.sync(write).catchError(
      (Object error, StackTrace stackTrace) =>
          _reportRelayError(relay.url, error, stackTrace),
    );
  }

  void _reportRelayError(String url, Object error, StackTrace stackTrace) {
    log(
      'Error from relay $url, continuing with other relays: $error',
      name: 'NostrClient',
      error: error,
      stackTrace: stackTrace,
    );
    _relayErrorSubject.add(
      RelayError(relayUrl: url, error: error, stackTrace: stackTrace),
    );
    delegate?.onRelayError(url, error, stackTrace);
  }

  Stream<BaseNostrEvent> stream() {
    final result = _relaySubject
        .distinctUnique()
        .map((_) => _relays.values)
        .switchMap(
          (relays) => Rx.merge(
            relays.map(
              (e) => e.eventStream
                  .onErrorResume((error, stackTrace) {
                    // TODO: consider adding retry logic for transient errors, with backoff
                    _reportRelayError(e.url, error, stackTrace);
                    return const Stream.empty();
                  })
                  .doOnData((event) {
                    log(
                      'Received event: ${event.toString()} from relay',
                      name: 'NostrClient',
                    );
                    delegate?.onRelayActivity(e.url);
                  }),
            ),
          ),
        )
        .doOnData((e) {
          log(
            'Received event: ${e.toString()} from relay',
            name: 'NostrClient',
          );
        })
        .asBroadcastStream();

    return result;
  }

  Future<dynamic> disconnectAndDispose() {
    // _streamSubscription?.cancel();
    // _streamSubscription = null;
    _relaySubject.close();
    _relayErrorSubject.close();

    return Future.wait([
      for (final relay in _relays.values) relay.disconnect(),
    ]).then((_) => _isConnected = false);
  }
}

final class RelayError {
  final String relayUrl;
  final Object error;
  final StackTrace? stackTrace;

  const RelayError({
    required this.relayUrl,
    required this.error,
    this.stackTrace,
  });

  @override
  String toString() => 'RelayError(relay: $relayUrl, error: $error)';
}
