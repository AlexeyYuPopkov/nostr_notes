import 'dart:convert';

import 'package:nostr/model/nostr_event.dart';
import 'package:nostr/nostr_client/channel_factory.dart';
import 'package:nostr/nostr_client/ws_channel.dart';

import 'fake_ws_channel.dart';

/// A relay that keeps the events it is sent, answers REQ with the matching
/// ones and pushes later matching events to open subscriptions.
final class FakeRelay {
  static const url = 'ws://relay.test';

  final _events = <NostrEvent>[];
  final _subscriptions = <String, List<Map<String, Object?>>>{};
  final _channels = <FakeWsChannel>[];

  /// Answers EVENT with a rejecting OK when false.
  bool acceptsEvents = true;

  List<NostrEvent> get events => List.unmodifiable(_events);

  ChannelFactory get channelFactory => _FakeChannelFactory(this);

  FakeWsChannel _connect(String url) {
    final channel = FakeWsChannel(url: url)..onSend = _onFrame;
    _channels.add(channel);
    return channel;
  }

  /// An event that reaches the relay from someone else.
  void publish(NostrEvent event) {
    _events.add(event);
    _pushToSubscriptions(event);
  }

  /// Answers on a later microtask, as a socket would: a reply sent while the
  /// client is still writing would reach no listener yet.
  void _onFrame(String frame, FakeWsChannel channel) {
    Future.microtask(() => _answer(frame, channel));
  }

  void _answer(String frame, FakeWsChannel channel) {
    final message = jsonDecode(frame) as List<Object?>;
    switch (message.first) {
      case 'REQ':
        _onReq(message, channel);
      case 'CLOSE':
        _subscriptions.remove(message[1]);
      case 'EVENT':
        _onEvent(message, channel);
    }
  }

  void _onReq(List<Object?> message, FakeWsChannel channel) {
    final subscriptionId = message[1] as String;
    final filters = message.skip(2).cast<Map<String, Object?>>().toList();
    _subscriptions[subscriptionId] = filters;

    for (final event in _events.where((e) => _matchesAny(filters, e))) {
      channel.receive(jsonEncode(['EVENT', subscriptionId, event.toJson()]));
    }
    channel.receive(jsonEncode(['EOSE', subscriptionId]));
  }

  void _onEvent(List<Object?> message, FakeWsChannel channel) {
    final event = NostrEvent.fromJson(message[1] as Map<String, dynamic>);
    if (acceptsEvents) {
      _events.add(event);
    }
    channel.receive(
      jsonEncode([
        'OK',
        event.id,
        acceptsEvents,
        acceptsEvents ? '' : 'blocked: test relay',
      ]),
    );
    if (acceptsEvents) {
      _pushToSubscriptions(event);
    }
  }

  void _pushToSubscriptions(NostrEvent event) {
    for (final MapEntry(key: id, value: filters) in _subscriptions.entries) {
      if (!_matchesAny(filters, event)) continue;
      for (final channel in _channels) {
        channel.receive(jsonEncode(['EVENT', id, event.toJson()]));
      }
    }
  }

  static bool _matchesAny(
    List<Map<String, Object?>> filters,
    NostrEvent event,
  ) => filters.any((filter) => _matches(filter, event));

  static bool _matches(Map<String, Object?> filter, NostrEvent event) {
    bool includes(String key, String value) {
      final values = filter[key] as List<Object?>?;
      return values == null || values.contains(value);
    }

    bool hasTag(String key) {
      final values = filter['#$key'] as List<Object?>?;
      return values == null ||
          event.tags.any(
            (tag) => tag.length > 1 && tag[0] == key && values.contains(tag[1]),
          );
    }

    final kinds = filter['kinds'] as List<Object?>?;
    final since = filter['since'] as int?;
    return (kinds == null || kinds.contains(event.kind)) &&
        includes('authors', event.pubkey) &&
        includes('ids', event.id) &&
        hasTag('p') &&
        hasTag('d') &&
        (since == null || event.createdAt >= since);
  }
}

final class _FakeChannelFactory implements ChannelFactory {
  final FakeRelay _relay;

  const _FakeChannelFactory(this._relay);

  @override
  WsChannel create(String url) => _relay._connect(url);
}
