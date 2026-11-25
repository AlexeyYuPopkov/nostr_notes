import 'package:flutter_test/flutter_test.dart';
import 'package:webrtc_call/webrtc_call.dart';

void main() {
  test('signs the expiry and user id the way coturn checks them', () {
    const expirySeconds = 1795200000;
    final now = DateTime.fromMillisecondsSinceEpoch(
      (expirySeconds - Duration.secondsPerHour) * 1000,
    );

    final credentials = TurnCredentials.mint(
      secret: 'test-secret',
      userId: 'alice',
      now: now,
    );

    expect(credentials.username, '$expirySeconds:alice');
    // python3: base64(hmac.new(b'test-secret', b'1795200000:alice', sha1))
    expect(credentials.credential, 'CO5YA26fYQb4BYqYG9CYuxfhyDE=');
  });
}
