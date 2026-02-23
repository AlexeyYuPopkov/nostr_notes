import 'dart:convert';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nostr_notes/common/domain/model/relay_health.dart';
import 'package:nostr_notes/services/nostr_client/channel_factory.dart';
import 'package:nostr_notes/unauth/presentation/onboarding/pages/onboarding_relays_page/widgets/relay_tile.dart';

import '../../tools/mock_wschannel.dart';

class MockChannelFactory extends Mock implements ChannelFactory {}

void _respondWithEventAndEose(dynamic data, MockWSChannel ch) {
  if (data is! String) return;
  final parsed = jsonDecode(data) as List;
  if (parsed[0] == 'REQ') {
    final subscriptionId = parsed[1] as String;
    ch.mockStream.add(
      jsonEncode([
        'EVENT',
        subscriptionId,
        {
          'id': 'abc123',
          'pubkey': 'pub123',
          'kind': 1,
          'content': 'test',
          'sig': 'sig123',
          'created_at': 1700000000,
          'tags': <List<String>>[],
        },
      ]),
    );
    ch.mockStream.add(jsonEncode(['EOSE', subscriptionId]));
  }
}

void _respondWithEoseOnly(dynamic data, MockWSChannel ch) {
  if (data is! String) return;
  final parsed = jsonDecode(data) as List;
  if (parsed[0] == 'REQ') {
    final subscriptionId = parsed[1] as String;
    ch.mockStream.add(jsonEncode(['EOSE', subscriptionId]));
  }
}

void main() {
  const relayUrl = 'wss://relay.example.com';
  late MockChannelFactory channelFactory;
  late MockWSChannel channel;

  setUp(() {
    channelFactory = MockChannelFactory();
    channel = MockWSChannel(url: relayUrl);
    when(() => channelFactory.create(relayUrl)).thenReturn(channel);
  });

  group('RelayTileVM', () {
    test('startMonitoring — connected relay, status becomes connected', () {
      FakeAsync().run((async) {
        channel.onAdd = _respondWithEventAndEose;
        final vm = RelayTileVM(
          url: relayUrl,
          isSelected: true,
          channelFactory: channelFactory,
        );

        expect(vm.isConnecting, false);
        expect(vm.status, isNull);

        vm.startMonitoring();
        expect(vm.isConnecting, true);

        async.flushMicrotasks();
        // debounceTime(Durations.medium1 = 250ms)
        async.elapse(const Duration(milliseconds: 400));

        expect(vm.status, RelayStatus.connected);
        expect(vm.isConnecting, false);

        vm.dispose();
        async.elapse(const Duration(seconds: 20));
      });
    });

    test('startMonitoring — no data relay, status becomes warning', () {
      FakeAsync().run((async) {
        channel.onAdd = _respondWithEoseOnly;
        final vm = RelayTileVM(
          url: relayUrl,
          isSelected: true,
          channelFactory: channelFactory,
        );

        vm.startMonitoring();
        async.flushMicrotasks();
        async.elapse(const Duration(milliseconds: 400));

        expect(vm.status, RelayStatus.warning);
        expect(vm.isConnecting, false);

        vm.dispose();
        async.elapse(const Duration(seconds: 20));
      });
    });

    test(
      'startMonitoring — unresponsive relay, timeout, status becomes disconnected',
      () {
        FakeAsync().run((async) {
          // No onAdd — relay never responds
          final vm = RelayTileVM(
            url: relayUrl,
            isSelected: true,
            channelFactory: channelFactory,
          );

          vm.startMonitoring();
          async.flushMicrotasks();
          // Timeout is 5 seconds (from RelaysMonitoringUsecaseImpl) + debounce 250ms
          async.elapse(const Duration(seconds: 6));

          expect(vm.status, RelayStatus.disconnected);
          expect(vm.isConnecting, false);

          vm.dispose();
          async.elapse(const Duration(seconds: 20));
        });
      },
    );

    test('startMonitoring called twice — second call is no-op', () {
      FakeAsync().run((async) {
        channel.onAdd = _respondWithEventAndEose;
        final vm = RelayTileVM(
          url: relayUrl,
          isSelected: true,
          channelFactory: channelFactory,
        );

        vm.startMonitoring();
        vm.startMonitoring(); // no-op

        async.flushMicrotasks();
        async.elapse(const Duration(milliseconds: 400));

        expect(vm.status, RelayStatus.connected);
        verify(() => channelFactory.create(relayUrl)).called(1);

        vm.dispose();
        async.elapse(const Duration(seconds: 20));
      });
    });

    test('stopMonitoring — resets state', () {
      FakeAsync().run((async) {
        channel.onAdd = _respondWithEventAndEose;
        final vm = RelayTileVM(
          url: relayUrl,
          isSelected: true,
          channelFactory: channelFactory,
        );

        vm.startMonitoring();
        async.flushMicrotasks();
        async.elapse(const Duration(milliseconds: 400));
        expect(vm.status, RelayStatus.connected);

        vm.stopMonitoring();
        expect(vm.status, isNull);
        expect(vm.isConnecting, false);

        vm.dispose();
        async.elapse(const Duration(seconds: 20));
      });
    });

    test('notifyListeners — called on state changes', () {
      FakeAsync().run((async) {
        channel.onAdd = _respondWithEventAndEose;
        final vm = RelayTileVM(
          url: relayUrl,
          isSelected: true,
          channelFactory: channelFactory,
        );

        int notificationCount = 0;
        vm.addListener(() => notificationCount++);

        vm.startMonitoring();
        // 1: isConnecting = true
        expect(notificationCount, 1);

        async.flushMicrotasks();
        async.elapse(const Duration(milliseconds: 400));

        // 2: _onRelaysStatus (isConnecting = false, status = connected)
        expect(notificationCount, 2);

        vm.stopMonitoring();
        // 3: stopMonitoring resets state
        expect(notificationCount, 3);

        vm.dispose();
        async.elapse(const Duration(seconds: 20));
      });
    });
  });
}
