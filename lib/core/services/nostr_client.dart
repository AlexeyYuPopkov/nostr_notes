import 'dart:async';

import 'package:nostr_notes/core/services/model/base_nostr_event.dart';
import 'package:nostr_notes/core/services/model/nostr_event.dart';
import 'package:nostr_notes/core/services/nostr_relay.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'model/nostr_req.dart';
import 'ws_channel.dart';

class ChannelFactory {
  const ChannelFactory();

  WsChannel create(String url) {
    return WsChannel(
      url: url,
      channel: WebSocketChannel.connect(
        Uri.parse(url),
      ),
    );
  }
}

final class NostrClient {
  NostrClient({
    ChannelFactory? channelFactory,
    Uuid? uuid,
  })  : _channelFactory = channelFactory ?? const ChannelFactory(),
        _uuid = uuid ?? const Uuid();

  final ChannelFactory _channelFactory;
  final Uuid _uuid;

  final _relays = <String, NostrRelay>{};

  int get count => _relays.length;

  bool _isConnected = false;

  void addRelay(String url) {
    final uri = Uri.tryParse(url);
    if (uri != null && !_relays.containsKey(url)) {
      final relay = NostrRelay(url: url, channelFactory: _channelFactory);
      _relays[url] = relay;
    }
  }

  void removeRelay(String url) {
    final relay = _relays[url];
    relay?.disconnect();
    _relays.remove(url);
  }

  void sendRequestToAll(NostrReq req) {
    final subscriptionId = _uuid.v1();
    for (final relay in _relays.values) {
      relay.sendEvent(req, subscriptionId);
    }
  }

  void publishEventToAll(NostrEvent event) {
    final subscriptionId = _uuid.v1();
    for (final relay in _relays.values) {
      relay.sendEvent(event, subscriptionId);
    }
  }

  FutureOr<void> connect() async {
    if (!_isConnected) {
      await Future.wait([
        for (final relay in _relays.values) relay.ready,
      ]);
      _isConnected = true;
    }
  }

  Stream<BaseNostrEvent> stream() {
    return Rx.merge([
      for (final relay in _relays.values) relay.events,
    ]);
  }

  Future<dynamic> disconnect() {
    return Future.wait([
      for (final relay in _relays.values) relay.disconnect(),
    ]);
  }
}
