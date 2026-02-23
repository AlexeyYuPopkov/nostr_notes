import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_notes/common/domain/model/relay_health.dart';
import 'package:nostr_notes/services/nostr_client/channel_factory.dart';
import 'package:nostr_notes/services/nostr_client/relay_monitoring.dart';
import 'package:web_socket_channel/io.dart';

void main() {
  group('RelayMonitoring', () {
    late HttpServer server;
    late StreamSubscription serverSubscription;
    late String relayUrl;

    Future<HttpServer> startServer({
      required void Function(IOWebSocketChannel channel, String request)
      onRequest,
    }) async {
      final srv = await HttpServer.bind(
        InternetAddress.loopbackIPv4,
        0,
        shared: true,
      );

      serverSubscription = srv.transform(WebSocketTransformer()).listen((
        WebSocket webSocket,
      ) {
        final channel = IOWebSocketChannel(webSocket);
        channel.stream.listen((request) {
          if (request is String) {
            onRequest(channel, request);
          }
        });
      });

      return srv;
    }

    tearDown(() async {
      await serverSubscription.cancel();
      await server.close();
    });

    test('connected — relay responds with EVENT + EOSE', () async {
      server = await startServer(
        onRequest: (channel, request) {
          final parsed = jsonDecode(request) as List;
          final type = parsed[0] as String;
          if (type != 'REQ') return;

          final subscriptionId = parsed[1] as String;

          channel.sink.add(
            jsonEncode([
              'EVENT',
              subscriptionId,
              {
                'id': 'abc123',
                'pubkey': 'pub123',
                'kind': 1,
                'content': 'hello',
                'sig': 'sig123',
                'created_at': 1700000000,
                'tags': [],
              },
            ]),
          );
          channel.sink.add(jsonEncode(['EOSE', subscriptionId]));
        },
      );

      relayUrl = 'ws://localhost:${server.port}';
      final sut = RelayMonitoring(
        url: Uri.parse(relayUrl),
        channelFactory: const ChannelFactory(),
        interval: const Duration(seconds: 60),
        timeout: const Duration(seconds: 3),
      );

      final statusFuture = sut.status.first;
      sut.start();

      final result = await statusFuture;
      expect(result, RelayHealth.connected);
      expect(sut.lastStatus, RelayHealth.connected);

      await sut.dispose();
    });

    test('empty — relay responds with EOSE only', () async {
      server = await startServer(
        onRequest: (channel, request) {
          final parsed = jsonDecode(request) as List;
          final type = parsed[0] as String;
          if (type != 'REQ') return;

          final subscriptionId = parsed[1] as String;
          channel.sink.add(jsonEncode(['EOSE', subscriptionId]));
        },
      );

      relayUrl = 'ws://localhost:${server.port}';
      final sut = RelayMonitoring(
        url: Uri.parse(relayUrl),
        channelFactory: const ChannelFactory(),
        interval: const Duration(seconds: 60),
        timeout: const Duration(seconds: 3),
      );

      final statusFuture = sut.status.first;
      sut.start();

      final result = await statusFuture;
      expect(result, RelayHealth.connectedNoData);
      expect(sut.lastStatus, RelayHealth.connectedNoData);

      await sut.dispose();
    });

    test('disconnected — relay does not respond within timeout', () async {
      server = await startServer(
        onRequest: (channel, request) {
          // No response — simulate unresponsive relay
        },
      );

      relayUrl = 'ws://localhost:${server.port}';
      final sut = RelayMonitoring(
        url: Uri.parse(relayUrl),
        channelFactory: const ChannelFactory(),
        interval: const Duration(seconds: 60),
        timeout: const Duration(milliseconds: 200),
      );

      final statusFuture = sut.status.first;
      sut.start();

      final result = await statusFuture;
      expect(result, RelayHealth.disconnected);
      expect(sut.lastStatus, RelayHealth.disconnected);

      await sut.dispose();
    });

    test('error — relay is not reachable', () async {
      // Bind server then immediately close to get an unused port
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final port = server.port;
      await server.close();

      // Re-create a server on a different port so tearDown doesn't fail
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      serverSubscription = server
          .transform(WebSocketTransformer())
          .listen((_) {});

      relayUrl = 'ws://localhost:$port';
      final sut = RelayMonitoring(
        url: Uri.parse(relayUrl),
        channelFactory: const ChannelFactory(),
        interval: const Duration(seconds: 60),
        timeout: const Duration(milliseconds: 200),
      );

      final statusFuture = sut.status.first;
      sut.start();

      final result = await statusFuture;
      expect(result, RelayHealth.error);

      await sut.dispose();
    });

    test('sends correct REQ filter', () async {
      final receivedRequests = <String>[];

      server = await startServer(
        onRequest: (channel, request) {
          receivedRequests.add(request);

          final parsed = jsonDecode(request) as List;
          final type = parsed[0] as String;
          if (type != 'REQ') return;

          final subscriptionId = parsed[1] as String;
          channel.sink.add(jsonEncode(['EOSE', subscriptionId]));
        },
      );

      relayUrl = 'ws://localhost:${server.port}';
      final sut = RelayMonitoring(
        url: Uri.parse(relayUrl),
        channelFactory: const ChannelFactory(),
        interval: const Duration(seconds: 60),
        timeout: const Duration(seconds: 3),
      );

      final statusFuture = sut.status.first;
      sut.start();
      await statusFuture;

      expect(receivedRequests.length, 1);

      final parsed = jsonDecode(receivedRequests.first) as List;
      expect(parsed[0], 'REQ');
      final filter = parsed[2] as Map<String, dynamic>;
      expect(filter['kinds'], [0, 1, 4, 7, 10002]);
      expect(filter['limit'], 1);

      await sut.dispose();
    });
  });
}
