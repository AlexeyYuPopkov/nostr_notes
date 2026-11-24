import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:webrtc_call/webrtc_call.dart';

final class FakeSignaling implements SignalingChannel {
  final sent = <SignalingMessage>[];
  final _messages = StreamController<SignalingMessage>.broadcast();
  final _connectionState = ValueNotifier(SignalingConnectionState.connected);

  void receive(SignalingMessage message) => _messages.add(message);

  @override
  ValueListenable<SignalingConnectionState> get connectionState =>
      _connectionState;

  @override
  Stream<SignalingMessage> get messages => _messages.stream;

  @override
  Future<void> connect({required SignalingPeer self}) async {}

  @override
  void send(SignalingMessage message) => sent.add(message);

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

final class FakePlatform implements WebRtcPlatform {
  final mediaConstraints = <Map<String, Object?>>[];
  final speakerphoneCalls = <bool>[];
  final switchedCameraTracks = <MediaStreamTrack>[];
  Exception? mediaError;
  late FakePeerConnection peerConnection;
  late FakeStream localStream;

  @override
  RTCVideoRenderer createRenderer() => FakeRenderer();

  @override
  Future<MediaStream> getUserMedia(Map<String, Object?> constraints) async {
    mediaConstraints.add(constraints);
    final error = mediaError;
    if (error != null) throw error;
    return localStream = FakeStream(hasVideo: constraints['video'] != false);
  }

  @override
  Future<RTCPeerConnection> createPeerConnection(
    Map<String, Object?> configuration,
  ) async => peerConnection = FakePeerConnection();

  @override
  Future<void> setSpeakerphoneOn(bool on) async => speakerphoneCalls.add(on);

  @override
  Future<void> switchCamera(MediaStreamTrack videoTrack) async =>
      switchedCameraTracks.add(videoTrack);
}

final class FakeRenderer extends RTCVideoRenderer {
  MediaStream? _stream;

  @override
  Future<void> initialize() async {}

  @override
  MediaStream? get srcObject => _stream;

  @override
  set srcObject(MediaStream? stream) => _stream = stream;
}

final class FakePeerConnection extends Fake implements RTCPeerConnection {
  final candidates = <RTCIceCandidate>[];
  RTCSessionDescription? remoteDescription;
  bool isClosed = false;

  @override
  void Function(RTCIceCandidate candidate)? onIceCandidate;

  @override
  void Function(RTCTrackEvent event)? onTrack;

  @override
  void Function(RTCPeerConnectionState state)? onConnectionState;

  @override
  Future<RTCSessionDescription> createOffer([
    Map<String, dynamic> constraints = const {},
  ]) async => RTCSessionDescription('local-offer', 'offer');

  @override
  Future<RTCSessionDescription> createAnswer([
    Map<String, dynamic> constraints = const {},
  ]) async => RTCSessionDescription('local-answer', 'answer');

  @override
  Future<void> setLocalDescription(RTCSessionDescription description) async {}

  @override
  Future<void> setRemoteDescription(RTCSessionDescription description) async {
    remoteDescription = description;
  }

  @override
  Future<void> addCandidate(RTCIceCandidate candidate) async {
    candidates.add(candidate);
  }

  @override
  Future<RTCRtpSender> addTrack(
    MediaStreamTrack track, [
    MediaStream? stream,
  ]) async => FakeSender();

  @override
  Future<void> close() async => isClosed = true;

  @override
  Future<void> dispose() async {}
}

final class FakeSender extends Fake implements RTCRtpSender {}

final class FakeStream extends Fake implements MediaStream {
  final audioTrack = FakeTrack('audio');
  final FakeTrack? videoTrack;

  FakeStream({required bool hasVideo})
    : videoTrack = hasVideo ? FakeTrack('video') : null;

  bool get isStopped =>
      getTracks().every((track) => track is FakeTrack && track.isStopped);

  @override
  List<MediaStreamTrack> getTracks() => [audioTrack, ?videoTrack];

  @override
  Future<void> dispose() async {}
}

final class FakeTrack extends Fake implements MediaStreamTrack {
  @override
  final String kind;

  @override
  bool enabled = true;

  bool isStopped = false;

  FakeTrack(this.kind);

  @override
  Future<void> stop() async => isStopped = true;
}
