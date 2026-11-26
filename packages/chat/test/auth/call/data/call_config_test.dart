import 'package:chat/auth/call/data/call_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webrtc_call/webrtc_call.dart';

void main() {
  final now = DateTime.utc(2026, 11, 25, 12);

  CallConfig config({String turnSecret = ''}) => CallConfig(
    signalingUri: Uri.parse('wss://signaling.test/ws'),
    turnSecret: turnSecret,
    iceTransportPolicy: IceTransportPolicy.all,
    turnCredentialsTtl: const Duration(minutes: 6),
  );

  test('ICE restarts with fresh TURN credentials before they expire', () {
    expect(
      config(turnSecret: 'secret').iceServersRefreshInterval,
      const Duration(minutes: 5),
    );
  });

  test('without TURN nothing needs refreshing', () {
    expect(config().iceServersRefreshInterval, isNull);
  });

  test('without a TURN secret a call has STUN only', () {
    final servers = config().iceServers(turnUserId: 'id', now: now);

    expect(servers.map((s) => s.urls), [
      ['stun:alekseiiapi.site:3478'],
    ]);
  });

  test('with a TURN secret a call gets UDP, TCP and TLS TURN', () {
    final [_, turn] = config(
      turnSecret: 'secret',
    ).iceServers(turnUserId: 'id', now: now);

    expect(turn.urls, [
      'turn:alekseiiapi.site:3478?transport=udp',
      'turn:alekseiiapi.site:3478?transport=tcp',
      'turns:alekseiiapi.site:443?transport=tcp',
    ]);
    final credentials = TurnCredentials.mint(
      secret: 'secret',
      userId: 'id',
      now: now,
      ttl: const Duration(minutes: 6),
    );
    expect(turn.username, credentials.username);
    expect(turn.credential, credentials.credential);
  });
}
