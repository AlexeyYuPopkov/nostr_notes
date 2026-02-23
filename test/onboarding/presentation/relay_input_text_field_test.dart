import 'dart:convert';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nostr_notes/services/nostr_client/channel_factory.dart';
import 'package:nostr_notes/unauth/presentation/onboarding/pages/onboarding_relays_page/widgets/relay_input_text_field.dart';

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

void main() {
  const relayUrl = 'wss://relay.example.com';
  late MockChannelFactory channelFactory;
  late MockWSChannel channel;

  setUp(() {
    channelFactory = MockChannelFactory();
    channel = MockWSChannel(url: relayUrl);
    when(() => channelFactory.create(relayUrl)).thenReturn(channel);
  });

  group('RelayInputTextFieldVM', () {
    test('canConnectToRelay — valid URL, relay responds, returns true', () {
      FakeAsync().run((async) {
        channel.onAdd = _respondWithEventAndEose;
        final vm = RelayInputTextFieldVM(channelFactory: channelFactory);

        bool? result;
        Future.value(vm.canConnectToRelay(relayUrl)).then((v) => result = v);

        async.flushMicrotasks();
        // Future.delayed(Durations.long2 = 500ms) + connection check
        async.elapse(const Duration(seconds: 2));
        async.flushMicrotasks();

        expect(result, true);
        expect(vm.canConnect, true);
        expect(vm.isConnecting, false);

        vm.dispose();
        async.elapse(const Duration(seconds: 20));
      });
    });

    test('canConnectToRelay — invalid URL, returns false immediately', () {
      FakeAsync().run((async) {
        final vm = RelayInputTextFieldVM(channelFactory: channelFactory);

        bool? result;
        Future.value(
          vm.canConnectToRelay('invalid-url'),
        ).then((v) => result = v);

        async.flushMicrotasks();

        expect(result, false);
        expect(vm.canConnect, isNull);
        expect(vm.isConnecting, false);

        vm.dispose();
      });
    });

    test(
      'canConnectToRelay — unresponsive relay, returns false after timeout',
      () {
        FakeAsync().run((async) {
          // No onAdd — relay never responds
          final vm = RelayInputTextFieldVM(channelFactory: channelFactory);

          bool? result;
          Future.value(vm.canConnectToRelay(relayUrl)).then((v) => result = v);

          async.flushMicrotasks();
          // Future.delayed(500ms) + timeout(5s)
          async.elapse(const Duration(seconds: 7));
          async.flushMicrotasks();

          expect(result, false);
          expect(vm.canConnect, false);
          expect(vm.isConnecting, false);

          vm.dispose();
          async.elapse(const Duration(seconds: 20));
        });
      },
    );

    test('isConnecting — true during check, false after', () {
      FakeAsync().run((async) {
        channel.onAdd = _respondWithEventAndEose;
        final vm = RelayInputTextFieldVM(channelFactory: channelFactory);

        vm.canConnectToRelay(relayUrl);
        async.flushMicrotasks();

        expect(vm.isConnecting, true);

        async.elapse(const Duration(seconds: 2));
        async.flushMicrotasks();

        expect(vm.isConnecting, false);

        vm.dispose();
        async.elapse(const Duration(seconds: 20));
      });
    });

    test('controller text change resets canConnect to null', () {
      FakeAsync().run((async) {
        channel.onAdd = _respondWithEventAndEose;
        final vm = RelayInputTextFieldVM(channelFactory: channelFactory);

        Future.value(vm.canConnectToRelay(relayUrl)).then((_) {});
        async.elapse(const Duration(seconds: 2));
        async.flushMicrotasks();

        expect(vm.canConnect, true);

        vm.controller.text = 'wss://other.relay.com';
        expect(vm.canConnect, isNull);

        vm.dispose();
        async.elapse(const Duration(seconds: 20));
      });
    });

    test('notifyListeners — called on state changes', () {
      FakeAsync().run((async) {
        channel.onAdd = _respondWithEventAndEose;
        final vm = RelayInputTextFieldVM(channelFactory: channelFactory);

        int notificationCount = 0;
        vm.addListener(() => notificationCount++);

        vm.canConnectToRelay(relayUrl);
        async.flushMicrotasks();

        // isConnecting = true
        expect(notificationCount, 1);

        async.elapse(const Duration(seconds: 2));
        async.flushMicrotasks();

        // isConnecting = false (finally block) — at least 2
        expect(notificationCount >= 2, true);

        vm.dispose();
        async.elapse(const Duration(seconds: 20));
      });
    });
  });
}
