import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../domain/ice_server.dart';
import '../domain/signaling_channel.dart';
import '../domain/signaling_message.dart';

/// One 1-1 call at a time over [SignalingChannel].
///
/// Incoming offers are answered right away while idle and rejected with a
/// bye while in a call; accept/decline comes with the call state machine.
final class PeerConnectionSession {
  final SignalingChannel _signaling;
  final String _selfId;
  final List<IceServer> _iceServers;

  final localRenderer = RTCVideoRenderer();
  final remoteRenderer = RTCVideoRenderer();

  final _peerId = ValueNotifier<String?>(null);
  final _connectionState = ValueNotifier<RTCPeerConnectionState?>(null);
  final _lastError = ValueNotifier<String?>(null);

  StreamSubscription<SignalingMessage>? _signalingSubscription;
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  String? _sessionId;
  bool _hasRemoteDescription = false;
  final _pendingCandidates = <RTCIceCandidate>[];

  PeerConnectionSession({
    required this._signaling,
    required this._selfId,
    required this._iceServers,
  });

  /// The other side of the current call, `null` while idle.
  ValueListenable<String?> get peerId => _peerId;

  ValueListenable<RTCPeerConnectionState?> get connectionState =>
      _connectionState;

  ValueListenable<String?> get lastError => _lastError;

  Future<void> initialize() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();
    _signalingSubscription = _signaling.messages.listen(_onSignalingMessage);
  }

  Future<void> call(String peerId) async {
    if (_sessionId != null) return;

    final sessionId = _signaling.sessionIdFor(
      callerId: _selfId,
      calleeId: peerId,
    );
    _startSession(sessionId: sessionId, peerId: peerId);

    await _guard(() async {
      final peerConnection = await _openPeerConnection(peerId);
      final offer = await peerConnection.createOffer();
      await peerConnection.setLocalDescription(offer);
      _signaling.send(
        SignalingOffer(
          from: _selfId,
          to: peerId,
          sessionId: sessionId,
          media: CallMedia.video,
          description: _toDescription(offer),
        ),
      );
    });
  }

  Future<void> hangUp() async {
    final sessionId = _sessionId;
    if (sessionId == null) return;
    _signaling.send(SignalingBye(sessionId: sessionId));
    await _closeSession();
  }

  Future<void> dispose() async {
    await _signalingSubscription?.cancel();
    await _closeSession();
    await localRenderer.dispose();
    await remoteRenderer.dispose();
    _peerId.dispose();
    _connectionState.dispose();
    _lastError.dispose();
  }

  Future<void> _onSignalingMessage(SignalingMessage message) async {
    switch (message) {
      case SignalingOffer():
        await _onOffer(message);
      case SignalingAnswer(:final sessionId) when sessionId == _sessionId:
        await _guard(() => _setRemoteDescription(message.description));
      case SignalingCandidate(:final sessionId) when sessionId == _sessionId:
        await _guard(() => _addRemoteCandidate(message.candidate));
      case SignalingBye(:final sessionId) when sessionId == _sessionId:
        await _closeSession();
      case SignalingError(:final reason) when _sessionId != null:
        _lastError.value = reason;
        await _closeSession();
      case SignalingAnswer() ||
          SignalingCandidate() ||
          SignalingBye() ||
          SignalingError() ||
          SignalingPeers():
        break;
    }
  }

  Future<void> _onOffer(SignalingOffer offer) async {
    if (_sessionId != null) {
      _signaling.send(SignalingBye(sessionId: offer.sessionId));
      return;
    }
    _startSession(sessionId: offer.sessionId, peerId: offer.from);

    await _guard(() async {
      final peerConnection = await _openPeerConnection(offer.from);
      await _setRemoteDescription(offer.description);
      final answer = await peerConnection.createAnswer();
      await peerConnection.setLocalDescription(answer);
      _signaling.send(
        SignalingAnswer(
          from: _selfId,
          to: offer.from,
          sessionId: offer.sessionId,
          description: _toDescription(answer),
        ),
      );
    });
  }

  void _startSession({required String sessionId, required String peerId}) {
    _sessionId = sessionId;
    _peerId.value = peerId;
    _lastError.value = null;
  }

  Future<RTCPeerConnection> _openPeerConnection(String peerId) async {
    final localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': {'facingMode': 'user'},
    });
    _localStream = localStream;
    localRenderer.srcObject = localStream;

    final peerConnection = await createPeerConnection({
      'iceServers': _iceServers.map((s) => s.toConfiguration()).toList(),
      'sdpSemantics': 'unified-plan',
    });
    _peerConnection = peerConnection;

    peerConnection.onIceCandidate = (candidate) {
      _sendLocalCandidate(candidate, peerId);
    };
    peerConnection.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        remoteRenderer.srcObject = event.streams.first;
      }
    };
    peerConnection.onConnectionState = (state) {
      _connectionState.value = state;
    };

    for (final track in localStream.getTracks()) {
      await peerConnection.addTrack(track, localStream);
    }
    return peerConnection;
  }

  void _sendLocalCandidate(RTCIceCandidate candidate, String peerId) {
    final sessionId = _sessionId;
    final value = candidate.candidate;
    if (sessionId == null || value == null) return;

    _signaling.send(
      SignalingCandidate(
        from: _selfId,
        to: peerId,
        sessionId: sessionId,
        candidate: IceCandidate(
          candidate: value,
          sdpMid: candidate.sdpMid,
          sdpMLineIndex: candidate.sdpMLineIndex,
        ),
      ),
    );
  }

  Future<void> _setRemoteDescription(SessionDescription description) async {
    final peerConnection = _peerConnection;
    if (peerConnection == null) return;

    await peerConnection.setRemoteDescription(
      RTCSessionDescription(description.sdp, description.type),
    );
    _hasRemoteDescription = true;

    final pending = List.of(_pendingCandidates);
    _pendingCandidates.clear();
    for (final candidate in pending) {
      await peerConnection.addCandidate(candidate);
    }
  }

  /// Candidates may arrive before the remote description is set; WebRTC
  /// rejects them until then, so they wait in [_pendingCandidates].
  Future<void> _addRemoteCandidate(IceCandidate candidate) async {
    final rtcCandidate = RTCIceCandidate(
      candidate.candidate,
      candidate.sdpMid,
      candidate.sdpMLineIndex,
    );
    final peerConnection = _peerConnection;
    if (peerConnection == null || !_hasRemoteDescription) {
      _pendingCandidates.add(rtcCandidate);
      return;
    }
    await peerConnection.addCandidate(rtcCandidate);
  }

  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } catch (error) {
      _lastError.value = error.toString();
      await _closeSession();
    }
  }

  Future<void> _closeSession() async {
    final peerConnection = _peerConnection;
    final localStream = _localStream;
    _peerConnection = null;
    _localStream = null;
    _sessionId = null;
    _hasRemoteDescription = false;
    _pendingCandidates.clear();

    localRenderer.srcObject = null;
    remoteRenderer.srcObject = null;
    await peerConnection?.close();
    await peerConnection?.dispose();
    if (localStream != null) {
      for (final track in localStream.getTracks()) {
        await track.stop();
      }
      await localStream.dispose();
    }

    _peerId.value = null;
    _connectionState.value = null;
  }

  static SessionDescription _toDescription(RTCSessionDescription description) =>
      SessionDescription(
        sdp: description.sdp ?? '',
        type: description.type ?? '',
      );
}
