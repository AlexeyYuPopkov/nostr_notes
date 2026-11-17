import 'package:flutter_test/flutter_test.dart';
import 'package:nostr/nostr_client/channel_factory.dart';
import 'package:nostr/nostr_client/relay_url_policy.dart';

void main() {
  group('RelayUrlPolicy.isAllowed', () {
    test('wss to any host', () {
      expect(RelayUrlPolicy.isAllowed('wss://relay.damus.io'), isTrue);
    });

    test('ws only to local hosts', () {
      expect(RelayUrlPolicy.isAllowed('ws://localhost:8008'), isTrue);
      expect(RelayUrlPolicy.isAllowed('ws://127.0.0.1:8008'), isTrue);
      expect(RelayUrlPolicy.isAllowed('ws://10.0.2.2:8008'), isTrue);
      expect(RelayUrlPolicy.isAllowed('ws://relay.damus.io'), isFalse);
      expect(RelayUrlPolicy.isAllowed('ws://localhost.evil.com'), isFalse);
      expect(RelayUrlPolicy.isAllowed('ws://evil.com/localhost'), isFalse);
    });

    test('other schemes and garbage', () {
      expect(RelayUrlPolicy.isAllowed('https://relay.damus.io'), isFalse);
      expect(RelayUrlPolicy.isAllowed('relay.damus.io'), isFalse);
      expect(RelayUrlPolicy.isAllowed(''), isFalse);
    });
  });

  test('ChannelFactory refuses ws:// to a public host', () {
    expect(
      () => const ChannelFactory().create('ws://relay.damus.io'),
      throwsA(isA<RelayUrlNotAllowedException>()),
    );
  });
}
