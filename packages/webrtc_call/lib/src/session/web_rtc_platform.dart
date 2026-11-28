import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;

/// The native WebRTC calls [PeerConnectionSession] makes, replaceable in tests.
abstract interface class WebRtcPlatform {
  webrtc.RTCVideoRenderer createRenderer();

  Future<webrtc.MediaStream> getUserMedia(Map<String, Object?> constraints);

  Future<webrtc.RTCPeerConnection> createPeerConnection(
    Map<String, Object?> configuration,
  );

  Future<void> setSpeakerphoneOn(bool on);

  Future<void> switchCamera(webrtc.MediaStreamTrack videoTrack);
}

final class FlutterWebRtcPlatform implements WebRtcPlatform {
  const FlutterWebRtcPlatform();

  @override
  webrtc.RTCVideoRenderer createRenderer() => webrtc.RTCVideoRenderer();

  @override
  Future<webrtc.MediaStream> getUserMedia(Map<String, Object?> constraints) =>
      webrtc.navigator.mediaDevices.getUserMedia(constraints);

  @override
  Future<webrtc.RTCPeerConnection> createPeerConnection(
    Map<String, Object?> configuration,
  ) => webrtc.createPeerConnection(configuration);

  @override
  Future<void> setSpeakerphoneOn(bool on) =>
      webrtc.Helper.setSpeakerphoneOn(on);

  @override
  Future<void> switchCamera(webrtc.MediaStreamTrack videoTrack) =>
      webrtc.Helper.switchCamera(videoTrack);
}
