import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_notes/services/channel_factory.dart';
import 'package:nostr_notes/services/nostr_client.dart';
import 'package:nostr_notes/services/model/base_nostr_event.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nostr_notes/services/ws_channel.dart';

class MockWSChannel extends Mock implements WsChannel {}

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
      channel1 = MockWSChannel();
      channel2 = MockWSChannel();
      client = NostrClient(channelFactory: channelFactory);
    });

    test('addRelay, connect, ready, removes relay', () async {
      when(() => channelFactory.create(relayUrl1)).thenReturn(channel1);
      when(() => channelFactory.create(relayUrl2)).thenReturn(channel2);

      client.addRelay(relayUrl1);
      client.addRelay(relayUrl1);
      client.addRelay(relayUrl2);

      expect(client.count, 2);

      when(() => channel1.stream).thenAnswer((_) => Stream.fromIterable([]));

      when(() => channel2.stream).thenAnswer((_) => Stream.fromIterable([]));

      expect(client.stream(), isA<Stream<BaseNostrEvent>>());

      when(() => channel1.ready).thenAnswer((_) => Future.value());
      when(() => channel2.ready).thenAnswer((_) => Future.value());

      await client.connect();

      verify(() => channel1.ready).called(1);
      verify(() => channel2.ready).called(1);

      when(() => channel1.disconnect()).thenAnswer((_) => Future.value());

      client.removeRelay(relayUrl1);
      verify(() => channel1.disconnect()).called(1);
      verifyNever(() => channel2.disconnect());
      expect(client.count, 1);

      when(() => channel2.disconnect()).thenAnswer((_) => Future.value());

      client.removeRelay(relayUrl2);
      verify(() => channel2.disconnect()).called(1);
      verifyNever(() => channel2.disconnect());
      expect(client.count, 0);
    });
  });
}
