import 'package:webrtc_call/webrtc_call.dart';

final class CallConfig {
  static const _signalingUrl = String.fromEnvironment(
    'SIGNALING_URL',
    defaultValue: 'wss://alekseiiapi.site:8086/ws',
  );

  /// Every signaling client sees it next to our pubkey in `peers`.
  static const clientName = 'nostr chat';

  final Uri signalingUri;
  final List<IceServer> iceServers;

  const CallConfig({required this.signalingUri, required this.iceServers});

  /// STUN only until TURN comes (doc/webrtc-assumptions.md, #4).
  factory CallConfig.fromEnvironment() => CallConfig(
    signalingUri: Uri.parse(_signalingUrl),
    iceServers: const [
      IceServer(urls: ['stun:alekseiiapi.site:3478']),
    ],
  );
}
