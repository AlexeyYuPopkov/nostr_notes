import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_notes/services/model/nostr_event.dart';
import 'package:nostr_notes/services/model/nostr_event_eose.dart';
import 'package:nostr_notes/services/model/nostr_filter.dart';
import 'package:nostr_notes/services/model/nostr_req.dart';
import 'package:nostr_notes/services/nostr_client.dart';
import 'package:nostr_notes/services/model/base_nostr_event.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nostr_notes/services/ws_channel.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/io.dart';

class MockWSChannel extends Mock implements WsChannel {}

class MockUuid extends Mock implements Uuid {}

void main() {
  group('NostrClient - request - responce', () {
    late HttpServer server;
    late StreamSubscription subscription;
    late NostrClient client;
    late MockUuid uuid = MockUuid();

    final List<String> requests = [];

    Future<void> setupSocket() async {
      server = await HttpServer.bind(
        InternetAddress.loopbackIPv4,
        0,
        shared: true,
      );

      subscription = server.transform(WebSocketTransformer()).listen((
        WebSocket webSocket,
      ) {
        final channel = IOWebSocketChannel(webSocket);

        channel.stream.listen((request) {
          if (request is String) {
            requests.add(request);
          }

          if (requests.length == 1) {
            channel.sink.add(
              r'["EVENT","uuid-v1",{"id":"9fe82b0ab2bb9d3b4523daaf947a17a050945ee2d45dca2c109785eff20cbcb9","pubkey":"dbbd7125eaead5470fa0f1c8e148fc866a0e0a24756d9e9964810d9007ff73f8","content":"fg3oLO54BQYBWmN22pNuhDxrm1xq36m7vZy8KnXBiDhX3o/xwZbDHttwmuMNvids/7LzkK6qB5LM9jVwBPolcJJN311GReBTrb3I3gr3G8i0Bwl2TZGYydpGyyKJDTW7?iv=3tikMldwry7sgWsnbcgo8Q==","sig":"a1c1328d90adb6b6f7590493761a893d9cabe6843890653b6f8a9b58168ffa9a86afb67f864b179e52083a60ed8b674a8c3e10e847aca85a79403814a2ba1a0f","kind":4,"created_at":1747690217,"tags":[["p","87e02be9ae3894742a3fedda2e6b33675b642800633ab8c7ac1a306f107ac81c"]]}]',
            );
            channel.sink.add(
              r'["EVENT","uuid-v1",{"id":"b6429ba094aa41ef040241f46b8390eb3ac7d42dd780558ccd20fb02fc0bbdba","pubkey":"3c316a662b851c0c2292a22099e0a7ef3a34234024987a669d2bd711bb42e850","content":"OeXjJDJTkdPs6paEqpAHjHuqMdMaaXDurwtXlofVeUzSsR88S5jd8nfVmh0COa21A5s9MpJSf1C/2OmmrL3RC9nl2jsE+HJNpcApikym/Skb/G+ADpcdLAkVk6PnFRJLLgPzmr2MOAn43JpAaFJLDw==?iv=3jyYiIaWabIyJrZyDEwXaw==","sig":"e2a62bea9de72b214f74c5f40bdf98e4e4cdb063de15e28cf28f9f6f0f65fcee24560fdd94f2073b124f25297fc89cdf6d2f31f46a3b658501188846ff38f569","kind":4,"created_at":1747690210,"tags":[["p","c04b100da6f8e89863f904e2a53c9ebb8902d2d6b9ae96d2187987c5effa5093"]]}]',
            );
            channel.sink.add(r'["EOSE","uuid-v1"]');
          }
        });
      });
    }

    setUp(() async {
      await setupSocket();
      client = NostrClient(uuid: uuid);
    });

    tearDown(() async {
      await subscription.cancel();
      await server.close();
    });

    test('request - responce', () async {
      final relayUrl = 'ws://localhost:${server.port}';
      client.addRelay(relayUrl);

      expect(client.count, 1);

      await client.connect();

      when(() => uuid.v1()).thenReturn('uuid-v1');

      client.sendRequestToAll(
        const NostrReq(
          filters: [
            NostrFilter(kinds: [4], limit: 5),
          ],
        ),
      );

      expect(
        client.stream(),
        emitsInOrder([
          predicate<NostrEvent>((event) {
            const exepted = r'''{"kind":4,
                "id":"9fe82b0ab2bb9d3b4523daaf947a17a050945ee2d45dca2c109785eff20cbcb9",
                "pubkey":"dbbd7125eaead5470fa0f1c8e148fc866a0e0a24756d9e9964810d9007ff73f8",
                "created_at":1747690217,
                "tags":[["p","87e02be9ae3894742a3fedda2e6b33675b642800633ab8c7ac1a306f107ac81c"]],
                "content":"fg3oLO54BQYBWmN22pNuhDxrm1xq36m7vZy8KnXBiDhX3o/xwZbDHttwmuMNvids/7LzkK6qB5LM9jVwBPolcJJN311GReBTrb3I3gr3G8i0Bwl2TZGYydpGyyKJDTW7?iv=3tikMldwry7sgWsnbcgo8Q==",
                "sig":"a1c1328d90adb6b6f7590493761a893d9cabe6843890653b6f8a9b58168ffa9a86afb67f864b179e52083a60ed8b674a8c3e10e847aca85a79403814a2ba1a0f"}''';

            return const DeepCollectionEquality().equals(
              event.toJson(),
              jsonDecode(exepted),
            );
          }),
          predicate<NostrEvent>((event) {
            const exepted = r'''{"kind":4,
            "id":"b6429ba094aa41ef040241f46b8390eb3ac7d42dd780558ccd20fb02fc0bbdba",
            "pubkey":"3c316a662b851c0c2292a22099e0a7ef3a34234024987a669d2bd711bb42e850",
            "created_at":1747690210,
            "tags":[["p","c04b100da6f8e89863f904e2a53c9ebb8902d2d6b9ae96d2187987c5effa5093"]],
            "content":"OeXjJDJTkdPs6paEqpAHjHuqMdMaaXDurwtXlofVeUzSsR88S5jd8nfVmh0COa21A5s9MpJSf1C/2OmmrL3RC9nl2jsE+HJNpcApikym/Skb/G+ADpcdLAkVk6PnFRJLLgPzmr2MOAn43JpAaFJLDw==?iv=3jyYiIaWabIyJrZyDEwXaw==",
            "sig":"e2a62bea9de72b214f74c5f40bdf98e4e4cdb063de15e28cf28f9f6f0f65fcee24560fdd94f2073b124f25297fc89cdf6d2f31f46a3b658501188846ff38f569"}''';
            return const DeepCollectionEquality().equals(
              event.toJson(),
              jsonDecode(exepted),
            );
          }),
          predicate<NostrEventEose>((event) {
            return event.eventType == EventType.eose &&
                event.subscriptionId == 'uuid-v1' &&
                event.relay == 'ws://localhost:${server.port}';
          }),
        ]),
      );
      while (requests.isEmpty) {
        await Future.delayed(const Duration(milliseconds: 10));
      }

      expect(requests.length, 1);

      expect(requests[0], r'["REQ","uuid-v1",{"kinds":[4],"limit":5}]');
    });
  });
}
