import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_notes/services/model/nostr_event_ok.dart';
import 'package:nostr_notes/services/nostr_client.dart';
import 'package:nostr_notes/services/nostr_event_creator.dart';
import 'package:web_socket_channel/io.dart';

void main() {
  group('NostrClient - publish event', () {
    late HttpServer server;
    late StreamSubscription subscription;
    late NostrClient client;

    final List<String> requests = [];

    Future<void> setupSocket() async {
      server = await HttpServer.bind(
        InternetAddress.loopbackIPv4,
        0,
        shared: true,
      );

      subscription = server
          .transform(WebSocketTransformer())
          .listen((WebSocket webSocket) {
        final channel = IOWebSocketChannel(webSocket);

        channel.stream.listen((request) {
          if (request is String) {
            requests.add(request);
          }

          if (requests.length == 1) {
            const responce = r'''
                  [
                    "OK",
                    "27c3b73a95dbdefc471d287f55bfc74c5c9e3fbc549f61fb42d916063498f047",
                    true,
                    ""
                  ]''';
            channel.sink.add(responce);
          }
        });
      });
    }

    setUp(() async {
      await setupSocket();
      client = NostrClient();
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

      const publicKey =
          'dce0fabd51911a780130715bb4c247df2fe0fe0e1c53df6218fa1e4e041e60e0';
      const privateKey =
          'a98fd7e7adff56cca03795e8dc80bdefbb2133ed0f2cda6e0c95b9dedb89f3a6';
      final event = NostrEventCreator.createEvent(
        kind: 4,
        content: '123',
        createdAt: DateTime(2025, 6, 16),
        tags: [
          ['p', publicKey],
        ],
        pubkey: publicKey,
        privateKey: privateKey,
      );

      final resultFuture = client.publishEventToAll(event);

      while (requests.isEmpty) {
        await Future.delayed(const Duration(milliseconds: 1));
      }

      const expectedRequest =
          r'["EVENT",{"kind":4,"id":"27c3b73a95dbdefc471d287f55bfc74c5c9e3fbc549f61fb42d916063498f047","pubkey":"dce0fabd51911a780130715bb4c247df2fe0fe0e1c53df6218fa1e4e041e60e0","created_at":1750021200,"tags":[["p","dce0fabd51911a780130715bb4c247df2fe0fe0e1c53df6218fa1e4e041e60e0"]],"content":"123","sig":"a61a90e8a1cbe7f8f2478bcb62c165cc056dfa9a831e8422018bd981d394285a21d8b45c583678974fcc9a5102266ae5d85b9b476054489934e3409c52c5ff15"}]';

      expect(requests.length, 1);
      expect(
        ((jsonDecode(requests[0]) as List)[1] as Map<String, dynamic>)
          ..remove('sig'),
        ((jsonDecode(expectedRequest) as List)[1] as Map<String, dynamic>)
          ..remove('sig'),
      );

      final exeptedEvent = NostrEventOk(
        relay: relayUrl,
        isOk: true,
        subscriptionId:
            '27c3b73a95dbdefc471d287f55bfc74c5c9e3fbc549f61fb42d916063498f047',
        message: '',
      );

      final subscription = client.stream().listen((e) {});

      await expectLater(
        resultFuture.then((e) => e.events.length),
        completion(1),
      );
      await expectLater(
        resultFuture.then((e) => e.events[0]),
        completion(exeptedEvent),
      );

      subscription.cancel();
    });
  });
}
