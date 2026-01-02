import 'dart:async';

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
      _uuid = uuid ?? const Uuid();

  final ChannelFactory _channelFactory;
  final Uuid _uuid;

  final _relays = <String, NostrRelay>{};
  Iterable<String> get relays => _relays.values.map((e) => e.url);

  StreamSubscription? _streamSubscription;
  late final _relaySubject = BehaviorSubject<Set<String>>.seeded({});

  int get count => _relays.length;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  Future<void> addRelay(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && !_relays.containsKey(url)) {
      await _addRelay(url);
      _relaySubject.add({...?_relaySubject.valueOrNull, url});
    }
  }

  Future<NostrRelay?> _addRelay(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && !_relays.containsKey(url)) {
      final relay = NostrRelay(url: url, channelFactory: _channelFactory);
      await relay.ready;
      _relays[url] = relay;
      return relay;
    } else {
      return null;
    }
  }

  Future<void> addRelays(Iterable<String> urls) async {
    for (final url in urls) {
      await _addRelay(url);
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

  Stream<BaseNostrEvent> stream() {
    // final result = _stream ??= Rx.merge([
    //   for (final relay in _relays.values) relay.eventStream,
    // ]).asBroadcastStream();

    // return result;

    final result = _relaySubject
        .distinctUnique()
        .map((_) => _relays.values)
        .switchMap((relays) => Rx.merge(relays.map((e) => e.eventStream)))
        .asBroadcastStream();

    return result;
  }

  Future<dynamic> disconnect() {
    _streamSubscription?.cancel();
    _streamSubscription = null;

    return Future.wait([
      for (final relay in _relays.values) relay.disconnect(),
    ]).then((_) => _isConnected = false);
  }
}
