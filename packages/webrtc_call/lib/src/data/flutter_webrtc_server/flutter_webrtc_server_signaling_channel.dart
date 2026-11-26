import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../domain/signaling_channel.dart';
import '../../domain/signaling_message.dart';
import 'flutter_webrtc_server_codec.dart';

typedef WebSocketConnector = WebSocketChannel Function(Uri uri);

/// [SignalingChannel] over the flutter-webrtc-server WebSocket (`/ws`).
///
/// Once connected it stays connected until [disconnect]: a dropped or silent
/// socket is reopened under the same id, and what is sent meanwhile waits.
final class FlutterWebrtcServerSignalingChannel implements SignalingChannel {
  /// The server splits `session_id` on it, so peer ids must not contain it.
  static const _sessionIdSeparator = '-';

  static const defaultReconnectDelays = [
    Duration(seconds: 1),
    Duration(seconds: 2),
    Duration(seconds: 4),
    Duration(seconds: 8),
    Duration(seconds: 10),
  ];

  /// A socket that receives nothing, not even the echo of a keepalive, for
  /// this long is taken for dead: after a network change it may never close.
  static const defaultKeepaliveInterval = Duration(seconds: 10);

  final Uri _uri;
  final WebSocketConnector _connectWebSocket;
  final List<Duration> _reconnectDelays;
  final Duration _keepaliveInterval;

  final _connectionState = ValueNotifier(SignalingConnectionState.disconnected);
  final _messages = StreamController<SignalingMessage>.broadcast();

  /// Who to register as again after a drop; `null` until [connect] and after
  /// [disconnect].
  SignalingPeer? _self;

  /// Bumped by [disconnect], so a connect still in flight knows it is stale.
  int _generation = 0;
  WebSocketChannel? _socket;
  StreamSubscription<Object?>? _socketSubscription;
  final _unsent = <String>[];
  Timer? _reconnectTimer;
  int _reconnectAttempt = 0;
  Timer? _keepaliveTimer;
  bool _receivedSinceKeepalive = false;

  FlutterWebrtcServerSignalingChannel({
    required this._uri,
    this._connectWebSocket = WebSocketChannel.connect,
    this._reconnectDelays = defaultReconnectDelays,
    this._keepaliveInterval = defaultKeepaliveInterval,
  });

  @override
  ValueListenable<SignalingConnectionState> get connectionState =>
      _connectionState;

  @override
  Stream<SignalingMessage> get messages => _messages.stream;

  /// Throws when the first connection fails; later drops are retried.
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
    _self = self;
    final generation = _generation;
    try {
      await _open(self, generation);
    } catch (_) {
      if (generation == _generation) await disconnect();
      rethrow;
    }
  }

  /// While reconnecting the message waits for the new socket.
  @override
  void send(SignalingMessage message) {
    final raw = FlutterWebrtcServerCodec.encode(message);
    final socket = _socket;
    if (socket != null) {
      socket.sink.add(raw);
    } else if (_self != null) {
      _unsent.add(raw);
    } else {
      throw StateError('Signaling is not connected');
    }
  }

  @override
  String sessionIdFor({required String callerId, required String calleeId}) =>
      '$callerId$_sessionIdSeparator$calleeId';

  @override
  Future<void> disconnect() async {
    _self = null;
    _generation++;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _reconnectAttempt = 0;
    _unsent.clear();
    final socket = _socket;
    _dropSocket();
    _connectionState.value = SignalingConnectionState.disconnected;
    await socket?.sink.close();
  }

  @override
  Future<void> dispose() async {
    await disconnect();
    await _messages.close();
    _connectionState.dispose();
  }

  Future<void> _open(SignalingPeer self, int generation) async {
    _connectionState.value = SignalingConnectionState.connecting;
    final socket = _connectWebSocket(_uri);
    await socket.ready;
    if (generation != _generation) {
      await socket.sink.close();
      throw StateError('Disconnected while connecting');
    }

    _socket = socket;
    _socketSubscription = socket.stream.listen(
      _onRawMessage,
      onDone: _onSocketLost,
      onError: (Object _) => _onSocketLost(),
    );
    socket.sink.add(FlutterWebrtcServerCodec.encodeNew(self));
    for (final raw in _unsent) {
      socket.sink.add(raw);
    }
    _unsent.clear();
    _reconnectAttempt = 0;
    _startKeepalive();
    _connectionState.value = SignalingConnectionState.connected;
  }

  void _onRawMessage(Object? raw) {
    _receivedSinceKeepalive = true;
    if (raw is! String) return;
    final message = FlutterWebrtcServerCodec.decode(raw);
    if (message != null) _messages.add(message);
  }

  void _startKeepalive() {
    _receivedSinceKeepalive = true;
    _keepaliveTimer = Timer.periodic(_keepaliveInterval, (_) {
      final socket = _socket;
      if (socket == null) return;
      if (!_receivedSinceKeepalive) {
        _log('no reply within ${_keepaliveInterval.inMilliseconds} ms');
        unawaited(socket.sink.close());
        _onSocketLost();
        return;
      }
      _receivedSinceKeepalive = false;
      socket.sink.add(FlutterWebrtcServerCodec.encodeKeepalive());
    });
  }

  void _onSocketLost() {
    if (_socket == null) return;
    _dropSocket();
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    final self = _self;
    if (self == null) {
      _connectionState.value = SignalingConnectionState.disconnected;
      return;
    }
    _connectionState.value = SignalingConnectionState.connecting;
    final delay =
        _reconnectDelays[min(_reconnectAttempt, _reconnectDelays.length - 1)];
    _reconnectAttempt++;
    _log('reconnecting in ${delay.inMilliseconds} ms');
    final generation = _generation;
    _reconnectTimer = Timer(delay, () => _reconnect(self, generation));
  }

  Future<void> _reconnect(SignalingPeer self, int generation) async {
    _reconnectTimer = null;
    try {
      await _open(self, generation);
      _log('reconnected');
    } catch (error) {
      if (generation != _generation) return;
      _log('reconnect failed: $error');
      _scheduleReconnect();
    }
  }

  void _dropSocket() {
    _keepaliveTimer?.cancel();
    _keepaliveTimer = null;
    unawaited(_socketSubscription?.cancel());
    _socketSubscription = null;
    _socket = null;
  }

  static void _log(String message) =>
      debugPrint('[FlutterWebrtcServerSignalingChannel] $message');
}
