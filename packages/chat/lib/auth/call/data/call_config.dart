import 'package:chat/common/domain/remote_settings.dart';
import 'package:webrtc_call/webrtc_call.dart';

/// Our signaling, STUN and TURN servers (doc/webrtc-backend.md §4, §6).
final class CallConfig {
  /// Local overrides for debugging; when set they win over Remote Config.
  static const _signalingUrlOverride = String.fromEnvironment('SIGNALING_URL');
  static const _relayOnlyOverride = bool.fromEnvironment('CALL_RELAY_ONLY');

  /// From config/turn.dev.json; dev builds only (doc/webrtc-assumptions.md,
  /// #3). Without it calls fall back to STUN.
  static const _turnDevSecret = String.fromEnvironment('TURN_DEV_SECRET');
  static const _turnTtlSeconds = int.fromEnvironment(
    'TURN_TTL_SECONDS',
    defaultValue: 3600,
  );

  final Uri signalingUri;
  final List<String> stunUrls;
  final List<String> turnUrls;
  final String turnSecret;
  final IceTransportPolicy iceTransportPolicy;
  final Duration turnCredentialsTtl;

  /// Every signaling client sees it next to our pubkey in `peers`.
  final String clientName;

  /// Also how long an incoming call invite stays fresh.
  final Duration answerTimeout;

  const CallConfig({
    required this.signalingUri,
    required this.stunUrls,
    required this.turnUrls,
    required this.turnSecret,
    required this.iceTransportPolicy,
    required this.clientName,
    required this.answerTimeout,
    this.turnCredentialsTtl = const Duration(hours: 1),
  });

  factory CallConfig.from(RemoteSettings settings) => CallConfig(
    signalingUri: _signalingUrlOverride.isEmpty
        ? settings.signalingUri
        : Uri.parse(_signalingUrlOverride),
    stunUrls: settings.stunUrls,
    turnUrls: settings.turnUrls,
    turnSecret: _turnDevSecret,
    iceTransportPolicy: _relayOnlyOverride || settings.callRelayOnly
        ? IceTransportPolicy.relay
        : IceTransportPolicy.all,
    clientName: settings.signalingClientName,
    answerTimeout: settings.callAnswerTimeout,
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
    final stun = IceServer(urls: stunUrls);
    if (!hasTurn) return [stun];
    final credentials = TurnCredentials.mint(
      secret: turnSecret,
      userId: turnUserId,
      now: now,
      ttl: turnCredentialsTtl,
    );
    return [
      stun,
      IceServer(
        urls: turnUrls,
        username: credentials.username,
        credential: credentials.credential,
      ),
    ];
  }
}
