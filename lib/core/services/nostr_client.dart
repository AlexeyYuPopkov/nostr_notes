import 'dart:async';

import 'package:nostr_notes/core/services/channel_factory.dart';
import 'package:nostr_notes/core/services/model/base_nostr_event.dart';
import 'package:nostr_notes/core/services/model/nostr_event.dart';
import 'package:nostr_notes/core/services/model/nostr_event_ok.dart';
import 'package:nostr_notes/core/services/nostr_event_ok_completer_map.dart';
import 'package:nostr_notes/core/services/nostr_relay.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';
import 'model/nostr_req.dart';

final class NostrClient {
  static const publishWindow = Duration(seconds: 2);
  NostrClient({
    ChannelFactory? channelFactory,
    Uuid? uuid,
  })  : _channelFactory = channelFactory ?? const ChannelFactory(),
        _uuid = uuid ?? const Uuid();

  final ChannelFactory _channelFactory;
  final Uuid _uuid;

  final _relays = <String, NostrRelay>{};
  final _eventOkMap = NostrEventOkCompleterMap();

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
      relay.sendRequest(req, subscriptionId);
    }
  }

  Future<List<NostrEventOk>> publishEventToAll(NostrEvent event) async {
    for (final relay in _relays.values) {
      _eventOkMap.add(
        relay: relay.url,
        event: event,
        completer: Completer<NostrEventOk>(),
      );
      relay.sendEvent(event);
    }

    final resultFuture = Future.wait(
      [
        for (final relay in _relays.values)
          _eventOkMap.getFuture(
            relay: relay.url,
            subscriptionId: event.id,
          ),
      ].nonNulls,
    );

    final result = await Future.any([
      resultFuture,
      Future.delayed(publishWindow),
    ]);

    if (result is List<NostrEventOk>) {
      return result;
    }

    throw const ErrorNostrClientPublishTimeout();
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
    ]).doOnData(
      (e) {
        if (e is NostrEventOk) {
          final completer = _eventOkMap.remove(
            relay: e.relay,
            subscriptionId: e.subscriptionId,
          );
          completer?.complete(e);
        }
      },
    );
  }

  Future<dynamic> disconnect() {
    return Future.wait([
      for (final relay in _relays.values) relay.disconnect(),
    ]);
  }
}

final class ErrorNostrClientPublishTimeout implements Exception {
  const ErrorNostrClientPublishTimeout();
  String get message =>
      'Publishing event to relays timed out after ${NostrClient.publishWindow}';
}
