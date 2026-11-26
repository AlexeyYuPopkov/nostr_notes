import 'package:webrtc_call/webrtc_call.dart';

/// Our signaling, STUN and TURN servers (doc/webrtc-backend.md §4, §6).
final class CallConfig {
  static const _signalingUrl = String.fromEnvironment(
    'SIGNALING_URL',
    defaultValue: 'wss://alekseiiapi.site:8086/ws',
  );

  /// From config/turn.dev.json; dev builds only (doc/webrtc-assumptions.md,
  /// #3). Without it calls fall back to STUN.
  static const _turnDevSecret = String.fromEnvironment('TURN_DEV_SECRET');
  static const _relayOnly = bool.fromEnvironment('CALL_RELAY_ONLY');
  static const _turnTtlSeconds = int.fromEnvironment(
    'TURN_TTL_SECONDS',
    defaultValue: 3600,
  );

  static const _stunUrls = ['stun:alekseiiapi.site:3478'];
  static const _turnUrls = [
    'turn:alekseiiapi.site:3478?transport=udp',
    'turn:alekseiiapi.site:3478?transport=tcp',
    'turns:alekseiiapi.site:443?transport=tcp',
  ];

  /// Every signaling client sees it next to our pubkey in `peers`.
  static const clientName = 'nostr chat';

  final Uri signalingUri;
  final String turnSecret;
  final IceTransportPolicy iceTransportPolicy;
  final Duration turnCredentialsTtl;

  const CallConfig({
    required this.signalingUri,
    required this.turnSecret,
    required this.iceTransportPolicy,
    this.turnCredentialsTtl = const Duration(hours: 1),
  });

  factory CallConfig.fromEnvironment() => CallConfig(
    signalingUri: Uri.parse(_signalingUrl),
    turnSecret: _turnDevSecret,
    iceTransportPolicy: _relayOnly
        ? IceTransportPolicy.relay
        : IceTransportPolicy.all,
    turnCredentialsTtl: const Duration(seconds: _turnTtlSeconds),
  );

  bool get hasTurn => turnSecret.isNotEmpty;

  /// A sixth of the lifetime is left for the restart to get through, e.g.
  /// 50 min of 1 h; `null` without TURN, where nothing expires.
  Duration? get iceServersRefreshInterval =>
      hasTurn ? turnCredentialsTtl * 5 ~/ 6 : null;

  /// Fresh TURN credentials each call; [turnUserId] only tells the TURN
  /// server's logs apart.
  List<IceServer> iceServers({
    required String turnUserId,
    required DateTime now,
  }) {
    if (!hasTurn) return const [IceServer(urls: _stunUrls)];
    final credentials = TurnCredentials.mint(
      secret: turnSecret,
      userId: turnUserId,
      now: now,
      ttl: turnCredentialsTtl,
    );
    return [
      const IceServer(urls: _stunUrls),
      IceServer(
        urls: _turnUrls,
        username: credentials.username,
        credential: credentials.credential,
      ),
    ];
  }
}
