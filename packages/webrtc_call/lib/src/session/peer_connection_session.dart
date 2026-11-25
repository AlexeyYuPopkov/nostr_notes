import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../domain/ice_server.dart';
import '../domain/signaling_channel.dart';
import '../domain/signaling_message.dart';
import 'web_rtc_platform.dart';

enum CallPhase {
  idle,

  /// Outgoing call until the answer arrives, including the wait for the
  /// callee to come online.
  calling,

  /// SDP exchanged, ICE still connecting.
  connecting,
  connected,
}

enum CallEndReason { hungUp, remoteHungUp, noAnswer, declined, failed }

/// One 1-1 call at a time over [SignalingChannel].
///
/// Incoming offers are answered right away while idle and rejected with a
/// bye while in a call: the callee joins signaling only once it accepts.
final class PeerConnectionSession {
  static const defaultAnswerTimeout = Duration(seconds: 45);

  /// The renderer binds to the stream's video track at the moment `srcObject`
  /// is set, so it is set when that track arrives, not with the audio one.
  static const _videoTrackKind = 'video';
  static const _audioTrackKind = 'audio';

  final SignalingChannel _signaling;
  final String _selfId;
  final List<IceServer> _iceServers;
  final WebRtcPlatform _platform;

  late final localRenderer = _platform.createRenderer();
  late final remoteRenderer = _platform.createRenderer();

  final _peerId = ValueNotifier<String?>(null);
  final _media = ValueNotifier<CallMedia?>(null);
  final _phase = ValueNotifier(CallPhase.idle);
  final _lastEndReason = ValueNotifier<CallEndReason?>(null);
  final _lastError = ValueNotifier<String?>(null);
  final _microphoneMuted = ValueNotifier(false);
  final _speakerOn = ValueNotifier(false);
  final _usingFrontCamera = ValueNotifier(true);

  StreamSubscription<SignalingMessage>? _signalingSubscription;
  Set<String> _onlinePeerIds = const {};

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  String? _sessionId;
  bool _offerSent = false;
  bool _hasRemoteDescription = false;
  Timer? _answerTimer;
  final _pendingCandidates = <RTCIceCandidate>[];

  PeerConnectionSession({
    required this._signaling,
    required this._selfId,
    required this._iceServers,
    this._platform = const FlutterWebRtcPlatform(),
  });

  /// The other side of the current call, `null` while idle.
  ValueListenable<String?> get peerId => _peerId;

  /// Media of the current call, `null` while idle.
  ValueListenable<CallMedia?> get media => _media;

  ValueListenable<CallPhase> get phase => _phase;

  /// Why the last call ended; reset when the next one starts.
  ValueListenable<CallEndReason?> get lastEndReason => _lastEndReason;

  /// Details for [CallEndReason.failed].
  ValueListenable<String?> get lastError => _lastError;

  ValueListenable<bool> get microphoneMuted => _microphoneMuted;

  /// Video calls start on the loudspeaker, audio calls on the earpiece.
  ValueListenable<bool> get speakerOn => _speakerOn;

  /// The local preview is mirrored only for the front camera.
  ValueListenable<bool> get usingFrontCamera => _usingFrontCamera;

  /// Call before the channel connects: who is online comes in the `peers`
  /// message the server sends right after joining.
  Future<void> initialize() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();
    _signalingSubscription = _signaling.messages.listen(_onSignalingMessage);
  }

  /// Calls [peerId], sending the offer once it is online.
  ///
  /// Ends with [CallEndReason.noAnswer] if no answer comes within
  /// [answerTimeout], counted from now.
  Future<void> call(
    String peerId, {
    required CallMedia media,
    Duration answerTimeout = defaultAnswerTimeout,
  }) async {
    if (_sessionId != null) return;

    final sessionId = _signaling.sessionIdFor(
      callerId: _selfId,
      calleeId: peerId,
    );
    _startSession(
      sessionId: sessionId,
      peerId: peerId,
      media: media,
      phase: CallPhase.calling,
    );
    _answerTimer = Timer(
      answerTimeout,
      () => _closeSession(CallEndReason.noAnswer),
    );

    await _guard(sessionId, () async {
      await _openPeerConnection(sessionId: sessionId, peerId: peerId);
      await _sendOfferIfPeerOnline();
    });
  }

  /// Waits for [peerId]'s call after accepting their invite; the offer is
  /// answered when it comes.
  ///
  /// Ends with [CallEndReason.noAnswer] if no offer comes within
  /// [offerTimeout], and with [CallEndReason.remoteHungUp] if [peerId] leaves
  /// the signaling server meanwhile.
  void awaitCall(
    String peerId, {
    required CallMedia media,
    Duration offerTimeout = defaultAnswerTimeout,
  }) {
    if (_sessionId != null) return;

    _startSession(
      sessionId: _signaling.sessionIdFor(callerId: peerId, calleeId: _selfId),
      peerId: peerId,
      media: media,
      phase: CallPhase.connecting,
    );
    _answerTimer = Timer(
      offerTimeout,
      () => _closeSession(CallEndReason.noAnswer),
    );
  }

  /// Ends a call the peer turned down by other means than signaling, e.g. a
  /// decline message; they never joined, so no bye is sent.
  Future<void> declinedByPeer() async {
    if (_sessionId == null) return;
    await _closeSession(CallEndReason.declined);
  }

  Future<void> hangUp() async {
    if (_sessionId == null) return;
    await _closeSession(CallEndReason.hungUp);
  }

  void setMicrophoneMuted(bool muted) {
    final localStream = _localStream;
    if (localStream == null) return;
    for (final track in _tracksOf(localStream, _audioTrackKind)) {
      track.enabled = !muted;
    }
    _microphoneMuted.value = muted;
  }

  Future<void> setSpeakerOn(bool on) async {
    if (_sessionId == null) return;
    await _platform.setSpeakerphoneOn(on);
    _speakerOn.value = on;
  }

  Future<void> switchCamera() async {
    final localStream = _localStream;
    if (localStream == null) return;
    for (final track in _tracksOf(localStream, _videoTrackKind)) {
      await _platform.switchCamera(track);
      _usingFrontCamera.value = !_usingFrontCamera.value;
    }
  }

  Future<void> dispose() async {
    await _closeSession(CallEndReason.hungUp);
    await _signalingSubscription?.cancel();
    await localRenderer.dispose();
    await remoteRenderer.dispose();
    _peerId.dispose();
    _media.dispose();
    _phase.dispose();
    _lastEndReason.dispose();
    _lastError.dispose();
    _microphoneMuted.dispose();
    _speakerOn.dispose();
    _usingFrontCamera.dispose();
  }

  Future<void> _onSignalingMessage(SignalingMessage message) async {
    final sessionId = _sessionId;
    switch (message) {
      case SignalingPeers(:final peers):
        await _onPeers(peers);
      case SignalingOffer():
        await _onOffer(message);
      case SignalingAnswer() when message.sessionId == sessionId:
        await _onAnswer(sessionId!, message.description);
      case SignalingCandidate() when message.sessionId == sessionId:
        await _guard(sessionId!, () => _addRemoteCandidate(message.candidate));
      case SignalingBye() when message.sessionId == sessionId:
        await _closeSession(CallEndReason.remoteHungUp);
      case SignalingError(:final reason) when sessionId != null:
        _lastError.value = reason;
        await _closeSession(CallEndReason.failed);
      case SignalingAnswer() ||
          SignalingCandidate() ||
          SignalingBye() ||
          SignalingError():
        break;
    }
  }

  Future<void> _onPeers(Set<SignalingPeer> peers) async {
    _onlinePeerIds = {for (final peer in peers) peer.id};

    final sessionId = _sessionId;
    if (sessionId == null) return;
    final peerWentOffline =
        _peerConnectionStarted && !_onlinePeerIds.contains(_peerId.value);
    if (peerWentOffline) {
      await _closeSession(CallEndReason.remoteHungUp);
      return;
    }
    await _guard(sessionId, _sendOfferIfPeerOnline);
  }

  /// The offer is sent or received: from here on the peer has to stay online.
  bool get _peerConnectionStarted =>
      _offerSent || _phase.value != CallPhase.calling;

  Future<void> _sendOfferIfPeerOnline() async {
    final peerConnection = _peerConnection;
    final sessionId = _sessionId;
    final peerId = _peerId.value;
    final media = _media.value;
    final canSendOffer =
        !_offerSent &&
        peerConnection != null &&
        sessionId != null &&
        peerId != null &&
        media != null &&
        _onlinePeerIds.contains(peerId);
    if (!canSendOffer) return;

    _offerSent = true;
    final offer = await peerConnection.createOffer();
    await peerConnection.setLocalDescription(offer);
    _ensureCurrent(sessionId);
    _signaling.send(
      SignalingOffer(
        from: _selfId,
        to: peerId,
        sessionId: sessionId,
        media: media,
        description: _toDescription(offer),
      ),
    );
  }

  Future<void> _onAnswer(String sessionId, SessionDescription answer) async {
    _answerTimer?.cancel();
    _phase.value = CallPhase.connecting;
    await _guard(sessionId, () => _setRemoteDescription(answer));
  }

  Future<void> _onOffer(SignalingOffer offer) async {
    final isAwaited =
        offer.sessionId == _sessionId &&
        offer.from == _peerId.value &&
        _peerConnection == null &&
        _phase.value == CallPhase.connecting;
    if (isAwaited) {
      _answerTimer?.cancel();
      _media.value = offer.media;
      await _answer(offer);
      return;
    }

    final isGlare =
        _sessionId != null &&
        offer.from == _peerId.value &&
        _phase.value == CallPhase.calling;
    if (isGlare && !_yieldsTo(offer.from)) {
      _log('glare with ${offer.from}: our offer wins, theirs is dropped');
      return;
    }
    if (_sessionId != null && !isGlare) {
      _log('busy: rejecting the offer from ${offer.from}');
      _signaling.send(SignalingBye(sessionId: offer.sessionId));
      return;
    }

    final abandoned = isGlare ? _detachCall() : null;
    if (abandoned != null) {
      _log('glare with ${offer.from}: answering their offer instead of ours');
    }
    final sessionId = offer.sessionId;
    _startSession(
      sessionId: sessionId,
      peerId: offer.from,
      media: offer.media,
      phase: CallPhase.connecting,
    );

    // Frees the camera before the answer asks for it again.
    await abandoned?.release();
    await _answer(offer);
  }

  Future<void> _answer(SignalingOffer offer) async {
    final sessionId = offer.sessionId;
    await _guard(sessionId, () async {
      final peerConnection = await _openPeerConnection(
        sessionId: sessionId,
        peerId: offer.from,
      );
      await _setRemoteDescription(offer.description);
      final answer = await peerConnection.createAnswer();
      await peerConnection.setLocalDescription(answer);
      _ensureCurrent(sessionId);
      _signaling.send(
        SignalingAnswer(
          from: _selfId,
          to: offer.from,
          sessionId: sessionId,
          description: _toDescription(answer),
        ),
      );
    });
  }

  /// When both sides call each other at once, the one with the greater id
  /// answers: the peer drops our offer silently, so no bye ends either call.
  bool _yieldsTo(String peerId) => peerId.compareTo(_selfId) < 0;

  void _startSession({
    required String sessionId,
    required String peerId,
    required CallMedia media,
    required CallPhase phase,
  }) {
    _sessionId = sessionId;
    _peerId.value = peerId;
    _media.value = media;
    _phase.value = phase;
    _lastEndReason.value = null;
    _lastError.value = null;
    _microphoneMuted.value = false;
    _usingFrontCamera.value = true;
  }

  Future<RTCPeerConnection> _openPeerConnection({
    required String sessionId,
    required String peerId,
  }) async {
    final isVideo = _media.value == CallMedia.video;
    final localStream = await _platform.getUserMedia({
      'audio': true,
      'video': isVideo ? {'facingMode': 'user'} : false,
    });
    if (_sessionId != sessionId) {
      await _release(localStream: localStream);
      throw const _SessionEnded();
    }
    _localStream = localStream;
    if (isVideo) localRenderer.srcObject = localStream;
    await setSpeakerOn(isVideo);

    final peerConnection = await _platform.createPeerConnection({
      'iceServers': _iceServers.map((s) => s.toConfiguration()).toList(),
      'sdpSemantics': 'unified-plan',
    });
    if (_sessionId != sessionId) {
      await _release(peerConnection: peerConnection);
      throw const _SessionEnded();
    }
    _peerConnection = peerConnection;

    // A connection dropped for another call may still fire while closing.
    bool isCurrent() => identical(_peerConnection, peerConnection);
    peerConnection.onIceCandidate = (candidate) {
      if (isCurrent()) _sendLocalCandidate(candidate, peerId);
    };
    peerConnection.onTrack = (event) {
      final isVideoTrack = event.track.kind == _videoTrackKind;
      if (isCurrent() && isVideoTrack && event.streams.isNotEmpty) {
        remoteRenderer.srcObject = event.streams.first;
      }
    };
    peerConnection.onConnectionState = (state) {
      if (isCurrent()) _onConnectionState(state);
    };

    for (final track in localStream.getTracks()) {
      await peerConnection.addTrack(track, localStream);
    }
    return peerConnection;
  }

  void _onConnectionState(RTCPeerConnectionState state) {
    switch (state) {
      case RTCPeerConnectionState.RTCPeerConnectionStateConnected:
        _phase.value = CallPhase.connected;
      case RTCPeerConnectionState.RTCPeerConnectionStateFailed:
        _lastError.value = 'ICE connection failed';
        unawaited(_closeSession(CallEndReason.failed));
      case RTCPeerConnectionState.RTCPeerConnectionStateNew ||
          RTCPeerConnectionState.RTCPeerConnectionStateConnecting ||
          RTCPeerConnectionState.RTCPeerConnectionStateDisconnected ||
          RTCPeerConnectionState.RTCPeerConnectionStateClosed:
        break;
    }
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

  /// Stops [sessionId]'s work once a hang-up or a bye has ended it.
  void _ensureCurrent(String sessionId) {
    if (_sessionId != sessionId) throw const _SessionEnded();
  }

  Future<void> _guard(String sessionId, Future<void> Function() action) async {
    try {
      await action();
    } on _SessionEnded {
      return;
    } catch (error) {
      if (_sessionId != sessionId) return;
      _lastError.value = error.toString();
      await _closeSession(CallEndReason.failed);
    }
  }

  Future<void> _closeSession(CallEndReason reason) async {
    final sessionId = _sessionId;
    if (sessionId == null) return;

    _log(
      'call $sessionId ended: ${reason.name}'
      '${_lastError.value == null ? '' : ' (${_lastError.value})'}',
    );
    final peerEndedIt =
        reason == CallEndReason.remoteHungUp ||
        reason == CallEndReason.declined;
    final peerKnowsOfCall = _offerSent || _hasRemoteDescription;
    if (!peerEndedIt && peerKnowsOfCall) {
      _signaling.send(SignalingBye(sessionId: sessionId));
    }
    final detached = _detachCall();

    // Listeners of [phase] read the reason as soon as the call goes idle.
    _lastEndReason.value = reason;
    _peerId.value = null;
    _media.value = null;
    _phase.value = CallPhase.idle;

    await detached.release();
  }

  /// Forgets the current call without notifying listeners; the caller
  /// releases what it returns.
  _DetachedCall _detachCall() {
    final detached = _DetachedCall(
      peerConnection: _peerConnection,
      localStream: _localStream,
    );
    _answerTimer?.cancel();
    _answerTimer = null;
    _peerConnection = null;
    _localStream = null;
    _sessionId = null;
    _offerSent = false;
    _hasRemoteDescription = false;
    _pendingCandidates.clear();
    localRenderer.srcObject = null;
    remoteRenderer.srcObject = null;
    return detached;
  }

  static void _log(String message) =>
      debugPrint('[PeerConnectionSession] $message');

  static Iterable<MediaStreamTrack> _tracksOf(
    MediaStream stream,
    String kind,
  ) => stream.getTracks().where((track) => track.kind == kind);

  static Future<void> _release({
    RTCPeerConnection? peerConnection,
    MediaStream? localStream,
  }) async {
    await peerConnection?.close();
    await peerConnection?.dispose();
    if (localStream == null) return;
    for (final track in localStream.getTracks()) {
      await track.stop();
    }
    await localStream.dispose();
  }

  static SessionDescription _toDescription(RTCSessionDescription description) =>
      SessionDescription(
        sdp: description.sdp ?? '',
        type: description.type ?? '',
      );
}

final class _SessionEnded implements Exception {
  const _SessionEnded();
}

final class _DetachedCall {
  final RTCPeerConnection? peerConnection;
  final MediaStream? localStream;

  const _DetachedCall({
    required this.peerConnection,
    required this.localStream,
  });

  Future<void> release() => PeerConnectionSession._release(
    peerConnection: peerConnection,
    localStream: localStream,
  );
}
