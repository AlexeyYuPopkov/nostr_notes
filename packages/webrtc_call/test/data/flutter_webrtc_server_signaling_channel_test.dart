import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:webrtc_call/webrtc_call.dart';

const _self = SignalingPeer(id: 'alice', name: 'Alice', userAgent: 'test');

void main() {
  late _FakeWebSocket socket;
  late FlutterWebrtcServerSignalingChannel channel;
  late List<Uri> connectedUris;

  setUp(() {
    socket = _FakeWebSocket();
    connectedUris = [];
    channel = FlutterWebrtcServerSignalingChannel(
      uri: Uri.parse('wss://signaling.test/ws'),
      connectWebSocket: (uri) {
        connectedUris.add(uri);
        return socket;
      },
    );
  });

  tearDown(() => channel.dispose());

  test('registers itself with "new" once connected', () async {
    await channel.connect(self: _self);

    expect(connectedUris, [Uri.parse('wss://signaling.test/ws')]);
    expect(channel.connectionState.value, SignalingConnectionState.connected);
    expect(socket.sentJson.single, {
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

    socket.receive('{}');
    socket.receive('{"type":"bye","data":{"session_id":"alice-bob"}}');
    await pumpEventQueue();

    expect(received, [const SignalingBye(sessionId: 'alice-bob')]);
  });

  test('sends encoded messages', () async {
    await channel.connect(self: _self);

    channel.send(const SignalingBye(sessionId: 'alice-bob'));

    expect(socket.sentJson.last, {
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

  test('reports disconnection when the server closes the socket', () async {
    await channel.connect(self: _self);

    await socket.closeFromServer();
    await pumpEventQueue();

    expect(
      channel.connectionState.value,
      SignalingConnectionState.disconnected,
    );
  });

  test('a failed handshake leaves the channel disconnected', () async {
    socket.failHandshake();

    await expectLater(channel.connect(self: _self), throwsA(isA<Exception>()));
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
