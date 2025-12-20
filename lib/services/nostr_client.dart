import 'dart:async';

import 'package:nostr_notes/services/channel_factory.dart';
import 'package:nostr_notes/services/model/base_nostr_event.dart';
import 'package:nostr_notes/services/model/nostr_event.dart';
import 'package:nostr_notes/services/model/nostr_event_ok.dart';
import 'package:nostr_notes/services/nostr_event_ok_completer_map.dart';
import 'package:nostr_notes/services/nostr_relay.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';
import 'model/nostr_req.dart';

final class NostrClient {
  static const publishWindow = Duration(seconds: 2);
  NostrClient({ChannelFactory? channelFactory, Uuid? uuid})
    : _channelFactory = channelFactory ?? const ChannelFactory(),
      _uuid = uuid ?? const Uuid();

  final ChannelFactory _channelFactory;
  final Uuid _uuid;

  final _relays = <String, NostrRelay>{};
  final _eventOkMap = NostrEventOkCompleterMap();
  Stream<BaseNostrEvent>? _stream;
  StreamSubscription? _streamSubscription;

  int get count => _relays.length;

  bool _isConnected = false;

  void addRelay(String url) {
    final uri = Uri.tryParse(url);
    if (uri != null && !_relays.containsKey(url)) {
      final relay = NostrRelay(url: url, channelFactory: _channelFactory);
      _relays[url] = relay;
    }
  }

  void addRelays(Iterable<String> urls) {
    for (final url in urls) {
      addRelay(url);
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

  Future<PublishEventReport> publishEventToAll(NostrEvent event) async {
    for (final relay in _relays.values) {
      _eventOkMap.add(
        relay: relay.url,
        event: event,
        completer: Completer<NostrEventOk>(),
      );
      relay.sendEvent(event);
    }

    final List<NostrEventOk> okEvents = [];

    final futures = [
      for (final relay in _relays.values)
        _eventOkMap
            .getFuture(relay: relay.url, subscriptionId: event.id)
            ?.then((e) => okEvents.add(e)),
    ].nonNulls;

    final resultFuture = Future.wait(futures);

    final result = await Future.any([
      resultFuture,
      Future.delayed(
        publishWindow,
      ).then((_) => const ErrorNostrClientPublishTimeout()),
    ]);

    if (result is ErrorNostrClientPublishTimeout) {
      return PublishEventReport(
        events: okEvents,
        timeoutError: result,
        targetEvent: event,
      );
    } else {
      return PublishEventReport(
        events: okEvents,
        timeoutError: null,
        targetEvent: event,
      );
    }
  }

  FutureOr<void> connect() async {
    if (!_isConnected) {
      _streamSubscription?.cancel();
      _streamSubscription = null;
      _stream = null;

      await Future.wait([for (final relay in _relays.values) relay.ready]);
      _isConnected = true;

      _streamSubscription = stream().listen((e) {
        if (e is NostrEventOk) {
          final completer = _eventOkMap.remove(
            relay: e.relay,
            subscriptionId: e.subscriptionId,
          );
          completer?.complete(e);
        }
      });
    }
  }

  Stream<BaseNostrEvent> stream() {
    final result = _stream ??= Rx.merge([
      for (final relay in _relays.values) relay.eventStream,
    ]).asBroadcastStream();

    return result;
  }

  Future<dynamic> disconnect() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
    _stream = null;
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

final class PublishEventReport {
  final ErrorNostrClientPublishTimeout? timeoutError;
  final List<NostrEventOk> events;
  final NostrEvent targetEvent;

  const PublishEventReport({
    required this.events,
    required this.timeoutError,
    required this.targetEvent,
  });
}
