import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:equatable/equatable.dart';

/// Time-limited TURN credentials of coturn's REST API (`use-auth-secret`).
final class TurnCredentials extends Equatable {
  final String username;
  final String credential;

  const TurnCredentials({required this.username, required this.credential});

  /// Signs `<expiry seconds>:<userId>` with [secret]; coturn accepts the
  /// result until [ttl] after [now] runs out.
  factory TurnCredentials.mint({
    required String secret,
    required String userId,
    required DateTime now,
    Duration ttl = const Duration(hours: 1),
  }) {
    final expirySeconds =
        now.add(ttl).millisecondsSinceEpoch ~/ Duration.millisecondsPerSecond;
    final username = '$expirySeconds:$userId';
    final mac = Hmac(sha1, utf8.encode(secret)).convert(utf8.encode(username));
    return TurnCredentials(
      username: username,
      credential: base64.encode(mac.bytes),
    );
  }

  @override
  List<Object?> get props => [username, credential];
}
