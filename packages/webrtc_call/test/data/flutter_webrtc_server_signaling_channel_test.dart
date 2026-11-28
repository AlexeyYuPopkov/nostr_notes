import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:webrtc_call/webrtc_call.dart';

const _self = SignalingPeer(id: 'alice', name: 'Alice', userAgent: 'test');

const _reconnectDelay = Duration(milliseconds: 10);
const _keepaliveInterval = Duration(milliseconds: 50);

void main() {
  late List<_FakeWebSocket> sockets;
  late FlutterWebrtcServerSignalingChannel channel;
  late List<Uri> connectedUris;
  var nextHandshakeFails = false;

  _FakeWebSocket socket() => sockets.last;

  setUp(() {
    sockets = [];
    connectedUris = [];
    nextHandshakeFails = false;
    channel = FlutterWebrtcServerSignalingChannel(
      uri: Uri.parse('wss://signaling.test/ws'),
      connectWebSocket: (uri) {
        connectedUris.add(uri);
        final socket = _FakeWebSocket();
        if (nextHandshakeFails) socket.failHandshake();
        sockets.add(socket);
        return socket;
      },
      reconnectDelays: const [_reconnectDelay],
      keepaliveInterval: _keepaliveInterval,
    );
  });

  Future<void> afterReconnectDelay() =>
      Future<void>.delayed(_reconnectDelay * 3);

  tearDown(() => channel.dispose());

  test('registers itself with "new" once connected', () async {
    await channel.connect(self: _self);

    expect(connectedUris, [Uri.parse('wss://signaling.test/ws')]);
    expect(channel.connectionState.value, SignalingConnectionState.connected);
    expect(socket().sentJson.single, {
      'type': 'new',
      'data': {'id': 'alice', 'name': 'Alice', 'user_agent': 'test'},
    });
  });

  test('rejects an id the server cannot put into a session id', () {
    expect(
      () => channel.connect(
        self: const SignalingPeer(id: 'a-b', name: '', userAgent: ''),
      ),
      throwsArgumentError,
    );
    expect(connectedUris, isEmpty);
  });

  test('delivers decoded messages and drops keep-alives', () async {
    await channel.connect(self: _self);
    final received = <SignalingMessage>[];
    channel.messages.listen(received.add);

    socket().receive('{}');
    socket().receive('{"type":"bye","data":{"session_id":"alice-bob"}}');
    await pumpEventQueue();

    expect(received, [const SignalingBye(sessionId: 'alice-bob')]);
  });

  test('sends encoded messages', () async {
    await channel.connect(self: _self);

    channel.send(const SignalingBye(sessionId: 'alice-bob'));

    expect(socket().sentJson.last, {
      'type': 'bye',
      'data': {'session_id': 'alice-bob'},
    });
  });

  test('sending while disconnected is a programming error', () {
    expect(
      () => channel.send(const SignalingBye(sessionId: 'alice-bob')),
      throwsStateError,
    );
  });

  group('after the socket is lost', () {
    test('reopens it and registers again under the same id', () async {
      await channel.connect(self: _self);

      await socket().closeFromServer();
      await pumpEventQueue();
      expect(
        channel.connectionState.value,
        SignalingConnectionState.connecting,
      );

      await afterReconnectDelay();
      expect(sockets, hasLength(2));
      expect(channel.connectionState.value, SignalingConnectionState.connected);
      expect(socket().sentJson.single, {
        'type': 'new',
        'data': {'id': 'alice', 'name': 'Alice', 'user_agent': 'test'},
      });
    });

    test('sends what was sent meanwhile once reopened', () async {
      await channel.connect(self: _self);
      await socket().closeFromServer();
      await pumpEventQueue();

      channel.send(const SignalingBye(sessionId: 'alice-bob'));
      await afterReconnectDelay();

      expect(socket().sentJson, [
        containsPair('type', 'new'),
        {
          'type': 'bye',
          'data': {'session_id': 'alice-bob'},
        },
      ]);
    });

    test('keeps retrying while the server is unreachable', () async {
      await channel.connect(self: _self);
      nextHandshakeFails = true;

      await socket().closeFromServer();
      await afterReconnectDelay();
      expect(
        channel.connectionState.value,
        SignalingConnectionState.connecting,
      );

      nextHandshakeFails = false;
      await afterReconnectDelay();
      expect(channel.connectionState.value, SignalingConnectionState.connected);
    });

    test('stops after disconnect', () async {
      await channel.connect(self: _self);
      await socket().closeFromServer();
      await pumpEventQueue();

      await channel.disconnect();
      await afterReconnectDelay();

      expect(sockets, hasLength(1));
      expect(
        channel.connectionState.value,
        SignalingConnectionState.disconnected,
      );
    });
  });

  group('keepalive', () {
    test('is sent while the server replies', () async {
      await channel.connect(self: _self);

      await Future<void>.delayed(_keepaliveInterval * 1.5);

      expect(socket().sentJson.last, {'type': 'keepalive', 'data': {}});
    });

    test('a socket that stays silent is reopened', () async {
      await channel.connect(self: _self);

      await Future<void>.delayed(_keepaliveInterval * 2.5);
      await afterReconnectDelay();

      expect(sockets, hasLength(greaterThan(1)));
    });

    test('a reply keeps the socket', () async {
      await channel.connect(self: _self);

      for (var i = 0; i < 3; i++) {
        await Future<void>.delayed(_keepaliveInterval * 0.8);
        socket().receive('{"type":"keepalive","data":{}}');
      }

      expect(sockets, hasLength(1));
    });
  });

  test('a failed first handshake leaves the channel disconnected', () async {
    nextHandshakeFails = true;

    await expectLater(channel.connect(self: _self), throwsA(isA<Exception>()));
    await afterReconnectDelay();
    expect(sockets, hasLength(1));
    expect(
      channel.connectionState.value,
      SignalingConnectionState.disconnected,
    );
  });

  test('session id joins caller and callee', () {
    expect(
      channel.sessionIdFor(callerId: 'alice', calleeId: 'bob'),
      'alice-bob',
    );
  });
}

final class _FakeWebSocket extends Fake implements WebSocketChannel {
  final _incoming = StreamController<Object?>();
  final _sink = _FakeSink();
  bool _handshakeFails = false;

  List<Object?> get sentJson =>
      _sink.sent.map((raw) => jsonDecode(raw! as String)).toList();

  void receive(String raw) => _incoming.add(raw);

  Future<void> closeFromServer() => _incoming.close();

  void failHandshake() => _handshakeFails = true;

  @override
  Future<void> get ready => _handshakeFails
      ? Future.error(WebSocketChannelException('refused'))
      : Future.value();

  @override
  Stream<Object?> get stream => _incoming.stream;

  @override
  WebSocketSink get sink => _sink;
}

final class _FakeSink extends Fake implements WebSocketSink {
  final sent = <Object?>[];

  @override
  void add(Object? data) => sent.add(data);

  @override
  Future<void> close([int? closeCode, String? closeReason]) async {}
}
