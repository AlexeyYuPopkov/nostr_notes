import 'package:flutter_test/flutter_test.dart';
import 'package:nostr/nostr_client/channel_factory.dart';
import 'package:nostr/nostr_client/nostr_client.dart';
import 'package:mocktail/mocktail.dart';

import '../mocks/mock_wschannel.dart';

class MockChannelFactory extends Mock implements ChannelFactory {}

void main() {
  group('NostrClient - add relays, remove relay', () {
    late NostrClient client;
    late MockChannelFactory channelFactory;
    late MockWSChannel channel1;
    late MockWSChannel channel2;

    const relayUrl1 = 'wss://relay1.example.com';
    const relayUrl2 = 'wss://relay2.example.com';

    setUp(() {
      channelFactory = MockChannelFactory();
      channel1 = MockWSChannel(url: relayUrl1);
      channel2 = MockWSChannel(url: relayUrl2);
      client = NostrClient(channelFactory: channelFactory);
    });

    test('addRelay, connect, ready, removes relay', () async {
      when(() => channelFactory.create(relayUrl1)).thenReturn(channel1);
      when(() => channelFactory.create(relayUrl2)).thenReturn(channel2);

      client.addRelay(relayUrl1);
      client.addRelay(relayUrl1);
      client.addRelay(relayUrl2);
      expect(client.count, 2);

      expect(channel1.verifyStreamCalled(), 1);
      expect(channel2.verifyStreamCalled(), 1);

      await client.removeRelay(relayUrl1);
      expect(channel1.verifyDisconnectCalled(), 1);
      expect(channel2.verifyDisconnectCalled(), 0);
      expect(client.count, 1);

      await client.removeRelay(relayUrl2);
      expect(channel1.verifyDisconnectCalled(), 1);
      expect(channel2.verifyDisconnectCalled(), 1);
      expect(client.count, 0);
    });

    group('addRelay - invalid URLs are rejected', () {
      final invalidUrls = [
        'https://relay.snort.social', // wrong scheme
        'http://relay.example.com', // wrong scheme
        'relay.example.com', // no scheme
        'wss://relay.snort.social:0', // port 0
        'wss://relay.snort.social#', // fragment
        'wss://relay.snort.social:0#', // port 0 + fragment
        '', // empty
        'ftp://relay.example.com', // wrong scheme
      ];

      for (final url in invalidUrls) {
        test('rejected: "$url"', () {
          verifyNever(() => channelFactory.create(any()));
          client.addRelay(url);
          expect(client.count, 0);
          verifyNever(() => channelFactory.create(any()));
        });
      }
    });

    group('addRelays - invalid URLs are filtered out', () {
      test('only valid URLs are added when mixed list provided', () {
        when(() => channelFactory.create(relayUrl1)).thenReturn(channel1);

        client.addRelays([
          relayUrl1,
          'https://relay.snort.social',
          'wss://relay.snort.social:0#',
        ]);

        expect(client.count, 1);
        verify(() => channelFactory.create(relayUrl1)).called(1);
        verifyNever(() => channelFactory.create('https://relay.snort.social'));
      });

      test('no relays added when all URLs invalid', () {
        client.addRelays([
          'https://relay.snort.social',
          'wss://relay.snort.social:0#',
        ]);

        expect(client.count, 0);
        verifyNever(() => channelFactory.create(any()));
      });
    });
  });
}
