import 'dart:async';

import 'package:chat/auth/call/domain/usecase/open_call_connection_usecase.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:webrtc_call/webrtc_call.dart';

/// Opens call sessions that keep calling and never connect: the camera and
/// microphone never come, and no one else is on the signaling server.
final class NeverConnectingCalls implements OpenCallConnectionUsecase {
  PeerConnectionSession? lastSession;

  @override
  Future<CallConnection> execute() async {
    final signaling = _SilentSignaling();
    final session = PeerConnectionSession(
      signaling: signaling,
      selfId: 'me',
      iceServers: () => const [],
      platform: const _MediaNeverComes(),
    );
    await session.initialize();
    lastSession = session;
    return _FakeCallConnection(session: session, signaling: signaling);
  }
}

final class _FakeCallConnection implements CallConnection {
  @override
  final PeerConnectionSession session;
  final _SilentSignaling _signaling;

  _FakeCallConnection({required this.session, required this._signaling});

  @override
  Future<void> close() async {
    await session.dispose();
    await _signaling.dispose();
  }
}

final class _SilentSignaling implements SignalingChannel {
  final _messages = StreamController<SignalingMessage>.broadcast();
  final _connectionState = ValueNotifier(SignalingConnectionState.connected);

  @override
  ValueListenable<SignalingConnectionState> get connectionState =>
      _connectionState;

  @override
  Stream<SignalingMessage> get messages => _messages.stream;

  @override
  Future<void> connect({required SignalingPeer self}) async {}

  @override
  void send(SignalingMessage message) {}

  @override
  String sessionIdFor({required String callerId, required String calleeId}) =>
      '$callerId-$calleeId';

  @override
  Future<void> disconnect() async {}

  @override
  Future<void> dispose() async {
    await _messages.close();
    _connectionState.dispose();
  }
}

final class _MediaNeverComes implements WebRtcPlatform {
  const _MediaNeverComes();

  @override
  RTCVideoRenderer createRenderer() => _OffscreenRenderer();

  @override
  Future<MediaStream> getUserMedia(Map<String, Object?> constraints) =>
      Completer<MediaStream>().future;

  @override
  Future<RTCPeerConnection> createPeerConnection(
    Map<String, Object?> configuration,
  ) => Completer<RTCPeerConnection>().future;

  @override
  Future<void> setSpeakerphoneOn(bool on) async {}

  @override
  Future<void> switchCamera(MediaStreamTrack videoTrack) async {}
}

/// The native renderer can't run in widget tests.
final class _OffscreenRenderer extends RTCVideoRenderer {
  MediaStream? _stream;

  @override
  Future<void> initialize() async {}

  @override
  MediaStream? get srcObject => _stream;

  @override
  set srcObject(MediaStream? stream) => _stream = stream;
}
