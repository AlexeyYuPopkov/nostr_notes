import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nostr/model/nostr_filter.dart';
import 'package:nostr/model/nostr_req.dart';
import 'package:nostr/nostr_client/async_fetcher.dart';
import 'package:nostr/nostr_client/channel_factory.dart';
import 'package:nostr/nostr_client/nostr_client.dart';
import 'package:uuid/uuid.dart';

import '../tools/mock_wschannel.dart';

class _MockChannelFactory extends Mock implements ChannelFactory {}

class _MockUuid extends Mock implements Uuid {}

const _relayUrl1 = 'ws://relay1.test';
const _relayUrl2 = 'ws://relay2.test';

String _eventJson(String subscriptionId, String eventId) {
  final event = {
    'kind': 1,
    'id': eventId,
    'pubkey': 'pubkey',
    'created_at': 1,
    'tags': <List<String>>[],
    'content': '',
    'sig': 'sig',
  };
  return '["EVENT","$subscriptionId",${jsonEncode(event)}]';
}

String _eoseJson(String subscriptionId) => '["EOSE","$subscriptionId"]';

void main() {
  group('AsyncFetcher', () {
    late _MockChannelFactory channelFactory;
    late _MockUuid uuid;
    late NostrClient client;
    late AsyncFetcher sut;

    setUp(() {
      channelFactory = _MockChannelFactory();
      uuid = _MockUuid();
      client = NostrClient(channelFactory: channelFactory, uuid: uuid);
      sut = AsyncFetcher(client: client);

      when(() => uuid.v4()).thenReturn('sub-id');
    });

    tearDown(() async {
      await client.disconnectAndDispose();
    });

    test(
      'returns an empty result immediately when there are no relays',
      () async {
        final result = await sut.fetchEvents(
          req: const NostrReq(filters: [NostrFilter(kinds: [1])]),
        );

        expect(result.events, isEmpty);
        expect(result.error, isNull);
        verifyNever(() => channelFactory.create(any()));
      },
    );

    test(
      'WaitForAllPolicy waits for EOSE from every relay before completing',
      () async {
        final channel1 = MockWSChannel(url: _relayUrl1);
        final channel2 = MockWSChannel(url: _relayUrl2);

        when(() => channelFactory.create(_relayUrl1)).thenReturn(channel1);
        when(() => channelFactory.create(_relayUrl2)).thenReturn(channel2);

        client.addRelay(_relayUrl1);
        client.addRelay(_relayUrl2);

        channel1.onAdd = (data, ch) {
          if ((data as String).contains('"REQ"')) {
            Future.microtask(() {
              ch.mockStream.add(_eventJson('sub-id', 'event-1'));
              ch.mockStream.add(_eoseJson('sub-id'));
            });
          }
        };

        channel2.onAdd = (data, ch) {
          if ((data as String).contains('"REQ"')) {
            Future.microtask(() {
              ch.mockStream.add(_eventJson('sub-id', 'event-2'));
              ch.mockStream.add(_eoseJson('sub-id'));
            });
          }
        };

        final result = await sut.fetchEvents(
          req: const NostrReq(filters: [NostrFilter(kinds: [1])]),
        );

        expect(result.error, isNull);
        expect(result.events.keys, containsAll(['event-1', 'event-2']));

        expect(
          channel1.calls.any(
            (c) => c.key == 'add' && (c.value as String).contains('"CLOSE"'),
          ),
          isTrue,
        );
        expect(
          channel2.calls.any(
            (c) => c.key == 'add' && (c.value as String).contains('"CLOSE"'),
          ),
          isTrue,
        );
      },
    );

    test(
      'ReturnFirstPolicy completes as soon as a single relay sends EOSE',
      () async {
        final channel1 = MockWSChannel(url: _relayUrl1);
        final channel2 = MockWSChannel(url: _relayUrl2);

        when(() => channelFactory.create(_relayUrl1)).thenReturn(channel1);
        when(() => channelFactory.create(_relayUrl2)).thenReturn(channel2);

        client.addRelay(_relayUrl1);
        client.addRelay(_relayUrl2);

        channel1.onAdd = (data, ch) {
          if ((data as String).contains('"REQ"')) {
            Future.microtask(() {
              ch.mockStream.add(_eventJson('sub-id', 'event-1'));
              ch.mockStream.add(_eoseJson('sub-id'));
            });
          }
        };
        // channel2 never sends EOSE.

        final result = await sut
            .fetchEvents(
              req: const NostrReq(filters: [NostrFilter(kinds: [1])]),
              policy: const ReturnFirstPolicy(),
            )
            .timeout(const Duration(seconds: 5));

        expect(result.error, isNull);
        expect(result.events.keys, contains('event-1'));
      },
    );

    test(
      'WaitForAllPolicy times out when not all relays send EOSE',
      () async {
        final channel1 = MockWSChannel(url: _relayUrl1);

        when(() => channelFactory.create(_relayUrl1)).thenReturn(channel1);

        client.addRelay(_relayUrl1);
        // channel1 never sends EOSE, so the request should time out.

        final result = await sut
            .fetchEvents(
              req: const NostrReq(filters: [NostrFilter(kinds: [1])]),
              policy: const WaitForAllPolicy(
                timeout: Duration(milliseconds: 50),
              ),
            )
            .timeout(const Duration(seconds: 5));

        expect(result.error, equals(AsyncFetchError.timoutError));
        expect(result.events, isEmpty);
      },
    );
  });
}
