import 'dart:convert';
import 'dart:developer';

import 'package:nostr_notes/services/channel_factory.dart';
import 'package:nostr_notes/services/model/base_nostr_event.dart';
import 'package:nostr_notes/services/model/nostr_event.dart';
import 'package:nostr_notes/services/model/nostr_event_eose.dart';
import 'package:nostr_notes/services/model/nostr_event_ok.dart';
import 'package:nostr_notes/services/model/nostr_req.dart';
import 'package:nostr_notes/services/ws_channel.dart';
import 'package:rxdart/rxdart.dart';

class NostrRelay with NostrRelayEventMapper {
  final WsChannel _channel;

  NostrRelay._({required WsChannel channel}) : _channel = channel;

  factory NostrRelay({
    required String url,
    required ChannelFactory channelFactory,
  }) {
    return NostrRelay._(channel: channelFactory.create(url));
  }

  @override
  String get url => _channel.url;

  Future<void> get ready {
    try {
      return _channel.ready;
    } catch (e) {
      log('NostrRelay.ready error: $e; $url', name: 'Nostr');
      rethrow;
    }
  }

  void sendRequest(NostrReq req, String subscriptionId) {
    _channel.add(req.serialized(subscriptionId));
  }

  void sendEvent(NostrEvent event) {
    _channel.add(event.serialized());
  }

  Stream<BaseNostrEvent> get eventStream {
    return _channel.stream.map(toNostrEvent).whereNotNull();
  }

  Future<dynamic> disconnect() => _channel.disconnect();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! NostrRelay) {
      return false;
    }
    return url == other.url;
  }

  @override
  int get hashCode => url.hashCode;
}

mixin NostrRelayEventMapper {
  String get url;

  BaseNostrEvent? toNostrEvent(data) {
    final content = jsonDecode(data) as List?;

    if (content == null) {
      return null;
    }

    final length = content.length;

    if (length < 2) {
      return null;
    }

    final type = content[0] as String?;
    final subscriptionId = content[1] as String?;

    if (type == null ||
        type.isEmpty ||
        subscriptionId == null ||
        subscriptionId.isEmpty) {
      return null;
    }

    if (type == EventType.eose.type) {
      return NostrEventEose(relay: url, subscriptionId: subscriptionId);
    }

    if (length < 3) {
      return null;
    }

    if (type == EventType.ok.type) {
      return NostrEventOk(
        relay: url,
        isOk: content[2] as bool? ?? false,
        subscriptionId: subscriptionId,
        message: content[3] as String? ?? '',
      );
    }

    final payload = content[2] as Map<String, dynamic>?;

    if (payload == null || payload.isEmpty) {
      return null;
    }

    try {
      return NostrEvent.fromJson(payload);
    } catch (e) {
      return null;
    }
  }
}
