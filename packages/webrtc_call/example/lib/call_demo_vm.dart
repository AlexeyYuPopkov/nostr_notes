import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:webrtc_call/webrtc_call.dart';

const _signalingUrl = String.fromEnvironment(
  'SIGNALING_URL',
  defaultValue: 'wss://alekseiiapi.site:8086/ws',
);

/// TURN joins in stage 2; until then calls behind CGNAT (LTE) may not connect.
const _iceServers = [
  IceServer(urls: ['stun:alekseiiapi.site:3478']),
];

final class CallDemoVm {
  final SignalingChannel _signaling;
  StreamSubscription<SignalingMessage>? _peersSubscription;

  final suggestedSelfId = _randomPeerId();
  final _session = ValueNotifier<PeerConnectionSession?>(null);
  final _otherPeers = ValueNotifier<List<SignalingPeer>>(const []);
  final _connectError = ValueNotifier<String?>(null);

  CallDemoVm()
    : _signaling = FlutterWebrtcServerSignalingChannel(
        uri: Uri.parse(_signalingUrl),
      );

  ValueListenable<SignalingConnectionState> get connectionState =>
      _signaling.connectionState;

  /// Set once connected; renderers and call state live there.
  ValueListenable<PeerConnectionSession?> get session => _session;

  ValueListenable<List<SignalingPeer>> get otherPeers => _otherPeers;

  ValueListenable<String?> get connectError => _connectError;

  Future<void> connect(String selfId) async {
    final id = selfId.trim();
    _connectError.value = null;

    try {
      final session = PeerConnectionSession(
        signaling: _signaling,
        selfId: id,
        iceServers: _iceServers,
      );
      await session.initialize();
      _session.value = session;

      _peersSubscription = _signaling.messages.listen((message) {
        if (message is SignalingPeers) {
          _otherPeers.value = message.peers.where((p) => p.id != id).toList();
        }
      });

      await _signaling.connect(
        self: SignalingPeer(
          id: id,
          name: 'webrtc_call example',
          userAgent: defaultTargetPlatform.name,
        ),
      );
    } catch (error) {
      _connectError.value = error.toString();
      await _release();
    }
  }

  Future<void> call(SignalingPeer peer) async => _session.value?.call(peer.id);

  Future<void> hangUp() async => _session.value?.hangUp();

  Future<void> disconnect() async {
    await _signaling.disconnect();
    await _release();
  }

  Future<void> dispose() async {
    await _release();
    await _signaling.dispose();
    _session.dispose();
    _otherPeers.dispose();
    _connectError.dispose();
  }

  Future<void> _release() async {
    await _peersSubscription?.cancel();
    _peersSubscription = null;
    final session = _session.value;
    _session.value = null;
    _otherPeers.value = const [];
    await session?.dispose();
  }

  /// Hex, so it never contains the `-` the signaling server forbids.
  static String _randomPeerId() {
    final random = Random();
    return List.generate(8, (_) => random.nextInt(16).toRadixString(16)).join();
  }
}
