import 'dart:convert';

import 'package:nostr_notes/services/model/nostr_event.dart';
import 'package:nostr_notes/services/model/nostr_req.dart';
import 'package:rxdart/rxdart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

final class NostrRelay {
  final String _url;
  final WebSocketChannel _channel;

  const NostrRelay._({
    required String url,
    required WebSocketChannel channel,
  })  : _url = url,
        _channel = channel;

  factory NostrRelay(
    String url, {
    // optional parameter for tests
    WebSocketChannel? channel,
  }) {
    return NostrRelay._(
      url: url,
      channel: channel ?? WebSocketChannel.connect(Uri.parse(url)),
    );
  }

  Future<void> connect() {
    return _channel.ready;
  }

  void sendEvent(NostrReq req) {
    _channel.sink.add(req.toJsonString());
  }

  Stream<NostrEvent> get events {
    return _channel.stream.map((data) {
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

      if (type == 'EOSE') {
        // TODO: parse EOSE
        return null;
      }

      if (length < 3) {
        return null;
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
    }).whereType<NostrEvent>();
  }

  void disconnect() {
    _channel.sink.close();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! NostrRelay) {
      return false;
    }
    return _url == other._url;
  }

  @override
  int get hashCode => _url.hashCode;
}
