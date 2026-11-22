import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../domain/signaling_channel.dart';
import '../../domain/signaling_message.dart';
import 'flutter_webrtc_server_codec.dart';

typedef WebSocketConnector = WebSocketChannel Function(Uri uri);

/// [SignalingChannel] over the flutter-webrtc-server WebSocket (`/ws`).
final class FlutterWebrtcServerSignalingChannel implements SignalingChannel {
  /// The server splits `session_id` on it, so peer ids must not contain it.
  static const _sessionIdSeparator = '-';

  final Uri _uri;
  final WebSocketConnector _connectWebSocket;

  final _connectionState = ValueNotifier(SignalingConnectionState.disconnected);
  final _messages = StreamController<SignalingMessage>.broadcast();

  WebSocketChannel? _socket;
  StreamSubscription<Object?>? _socketSubscription;

  FlutterWebrtcServerSignalingChannel({
    required this._uri,
    this._connectWebSocket = WebSocketChannel.connect,
  });

  @override
  ValueListenable<SignalingConnectionState> get connectionState =>
      _connectionState;

  @override
  Stream<SignalingMessage> get messages => _messages.stream;

  @override
  Future<void> connect({required SignalingPeer self}) async {
    if (self.id.isEmpty || self.id.contains(_sessionIdSeparator)) {
      throw ArgumentError.value(
        self.id,
        'self.id',
        'must be non-empty and must not contain "$_sessionIdSeparator"',
      );
    }

    await disconnect();
    _connectionState.value = SignalingConnectionState.connecting;

    final socket = _connectWebSocket(_uri);
    _socket = socket;
    try {
      await socket.ready;
    } catch (_) {
      _closeSocket();
      rethrow;
    }

    _socketSubscription = socket.stream.listen(
      _onRawMessage,
      onDone: _closeSocket,
      onError: (Object _) => _closeSocket(),
    );
    socket.sink.add(FlutterWebrtcServerCodec.encodeNew(self));
    _connectionState.value = SignalingConnectionState.connected;
  }

  @override
  void send(SignalingMessage message) {
    final socket = _socket;
    if (socket == null) {
      throw StateError('Signaling is not connected');
    }
    socket.sink.add(FlutterWebrtcServerCodec.encode(message));
  }

  @override
  String sessionIdFor({required String callerId, required String calleeId}) =>
      '$callerId$_sessionIdSeparator$calleeId';

  @override
  Future<void> disconnect() async {
    final socket = _socket;
    _closeSocket();
    await socket?.sink.close();
  }

  @override
  Future<void> dispose() async {
    await disconnect();
    await _messages.close();
    _connectionState.dispose();
  }

  void _onRawMessage(Object? raw) {
    if (raw is! String) return;
    final message = FlutterWebrtcServerCodec.decode(raw);
    if (message != null) _messages.add(message);
  }

  void _closeSocket() {
    _socketSubscription?.cancel();
    _socketSubscription = null;
    _socket = null;
    _connectionState.value = SignalingConnectionState.disconnected;
  }
}
