import 'dart:async';
import 'dart:developer';

import 'package:nostr_notes/services/model/nostr_event_close.dart';
import 'package:nostr_notes/services/nostr_client/channel_factory.dart';
import 'package:nostr_notes/services/model/base_nostr_event.dart';
import 'package:nostr_notes/services/model/nostr_event.dart';
import 'package:nostr_notes/services/nostr_client/nostr_relay.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';
import '../model/nostr_req.dart';

final class NostrClient {
  NostrClient({ChannelFactory? channelFactory, Uuid? uuid})
    : _channelFactory = channelFactory ?? const ChannelFactory(),
      _uuid = uuid ?? const Uuid() {
    log('NostrClientVariant - init', name: 'NostrClientVariant');
  }

  final ChannelFactory _channelFactory;
  final Uuid _uuid;

  final _relays = <String, NostrRelay>{};
  Iterable<String> get relays => _relays.values.map((e) => e.url);
  List<String> get relaysList => List.unmodifiable(relays);

  StreamSubscription? _streamSubscription;
  late final _relaySubject = BehaviorSubject<Set<String>>.seeded({});
  final _relayErrorSubject = PublishSubject<RelayError>();

  /// Stream of non-fatal relay errors (connection failures, timeouts, etc.).
  /// These errors don't interrupt the main event stream.
  Stream<RelayError> get relayErrors => _relayErrorSubject.stream;

  int get count => _relays.length;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  void addRelay(String url) {
    final uri = Uri.tryParse(url);
    if (uri != null && !_relays.containsKey(url)) {
      _addRelay(url);
      _relaySubject.add({...?_relaySubject.valueOrNull, url});
    }
  }

  NostrRelay? _addRelay(String url) {
    final uri = Uri.tryParse(url);
    if (uri != null && !_relays.containsKey(url)) {
      final relay = NostrRelay(url: url, channelFactory: _channelFactory);
      // await relay.ready;
      _relays[url] = relay;
      return relay;
    } else {
      return null;
    }
  }

  void addRelays(Iterable<String> urls) async {
    for (final url in urls) {
      _addRelay(url);
    }
    _relaySubject.add({...?_relaySubject.valueOrNull, ...urls});
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
      relay.sendRequest(req, subscriptionId);
    }
    return subscriptionId;
  }

  void sendEventToAll(NostrEvent event) {
    for (final relay in _relays.values) {
      // Future.microtask(() => relay.sendEvent(event));
      relay.sendEvent(event);
    }
  }

  void sendCloseForAll(String subscriptionId) {
    for (final relay in _relays.values) {
      relay.closeRequest(
        NostrEventClose(relay: relay.url, subscriptionId: subscriptionId),
      );
    }
  }

  void sendClose(String subscriptionId, String relayUrl) {
    for (final relay in _relays.values) {
      if (relay.url == relayUrl) {
        relay.closeRequest(
          NostrEventClose(relay: relay.url, subscriptionId: subscriptionId),
        );
      }
    }
  }

  Stream<BaseNostrEvent> stream() {
    final result = _relaySubject
        .distinctUnique()
        .map((_) => _relays.values)
        .switchMap(
          (relays) => Rx.merge(
            relays.map(
              (e) => e.eventStream.onErrorResume((error, stackTrace) {
                // TODO: consider adding retry logic for transient errors, with backoff
                log(
                  'Error from relay ${e.url}, continuing with other relays: $error',
                  name: 'NostrClient',
                  error: error,
                  stackTrace: stackTrace,
                );
                _relayErrorSubject.add(
                  RelayError(
                    relayUrl: e.url,
                    error: error,
                    stackTrace: stackTrace,
                  ),
                );
                return const Stream.empty();
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
    _streamSubscription?.cancel();
    _streamSubscription = null;
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
