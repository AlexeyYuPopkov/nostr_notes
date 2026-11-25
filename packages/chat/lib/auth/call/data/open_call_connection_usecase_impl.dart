import 'package:chat/auth/call/data/call_config.dart';
import 'package:chat/auth/call/domain/usecase/open_call_connection_usecase.dart';
import 'package:chat/common/domain/usecase/session_usecase.dart';
import 'package:flutter/foundation.dart';
import 'package:nostr/key_tool/key_tool.dart';
import 'package:webrtc_call/webrtc_call.dart';

final class OpenCallConnectionUsecaseImpl implements OpenCallConnectionUsecase {
  /// Enough to tell calls apart in the TURN server's logs.
  static const _turnUserIdLength = 16;

  final SessionUsecase _sessionUsecase;
  final CallConfig _config;
  final DateTime Function() _now;

  OpenCallConnectionUsecaseImpl({
    required this._sessionUsecase,
    required this._config,
    this._now = DateTime.now,
  });

  @override
  Future<CallConnection> execute() async {
    final selfId = _sessionUsecase.currentSession.pubkey;
    final signaling = FlutterWebrtcServerSignalingChannel(
      uri: _config.signalingUri,
    );
    final session = PeerConnectionSession(
      signaling: signaling,
      selfId: selfId,
      // A random id rather than the pubkey keeps who calls out of TURN logs.
      iceServers: _config.iceServers(
        turnUserId: KeyTool.random64HexChars().substring(0, _turnUserIdLength),
        now: _now(),
      ),
      iceTransportPolicy: _config.iceTransportPolicy,
    );
    final connection = _CallConnection(session: session, signaling: signaling);

    try {
      await session.initialize();
      await signaling.connect(
        self: SignalingPeer(
          id: selfId,
          name: CallConfig.clientName,
          userAgent: defaultTargetPlatform.name,
        ),
      );
    } catch (_) {
      await connection.close();
      rethrow;
    }
    return connection;
  }
}

final class _CallConnection implements CallConnection {
  @override
  final PeerConnectionSession session;
  final SignalingChannel _signaling;

  _CallConnection({required this.session, required this._signaling});

  @override
  Future<void> close() async {
    await session.dispose();
    await _signaling.dispose();
  }
}
