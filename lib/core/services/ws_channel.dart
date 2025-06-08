import 'package:web_socket_channel/web_socket_channel.dart';

class WsChannel {
  final String _url;
  final WebSocketChannel _channel;

  const WsChannel({
    required String url,
    required WebSocketChannel channel,
  })  : _url = url,
        _channel = channel;

  String get url => _url;

  Future<void> get ready => _channel.ready;

  void add(dynamic data) => _channel.sink.add(data);

  Stream<dynamic> get stream => _channel.stream;

  Future<dynamic> disconnect() => _channel.sink.close();
}
