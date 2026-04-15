import 'dart:async';

import 'package:web_socket_channel/web_socket_channel.dart';

class WsChannel {
  WsChannel({required String url, required WebSocketChannel channel})
    : _url = url,
      _channel = channel;
  final String _url;
  final WebSocketChannel _channel;
  bool _isReady = false;

  String get url => _url;

  FutureOr<void> _ensureReady() async {
    if (!_isReady) {
      await _channel.ready;
      _isReady = true;
    }
  }

  FutureOr<void> add(dynamic data) async {
    await _ensureReady();
    _channel.sink.add(data);
  }

  Stream<dynamic> get stream => _channel.stream;

  Future<dynamic> disconnect() => _channel.sink.close();
}
