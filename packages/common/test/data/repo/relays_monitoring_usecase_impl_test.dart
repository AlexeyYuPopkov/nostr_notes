import 'dart:async';

import 'package:common/data/repo/relays_monitoring_usecase_impl.dart';
import 'package:common/domain/repo/app_lifecycle_listener_repository.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr/model/relay_health.dart';
import 'package:nostr/nostr_client/channel_factory.dart';
import 'package:nostr/nostr_client/nostr_client.dart';
import 'package:nostr/nostr_client/relays_monitor.dart';
import 'package:nostr/nostr_client/ws_channel.dart';
import 'package:rxdart/rxdart.dart';

import '../../tools/moks.dart';

/// Hand-rolled instead of mocktail: RelaysMonitoringUsecaseImpl only reads
/// one stream off this dependency — same fake verification_widget_test.dart
/// uses for the identical interface.
final class _FakeAppLifecycleListenerRepository
    implements AppLifecycleListenerRepository {
  @override
  final PublishSubject<bool> isActiveStream = PublishSubject();

  @override
  Future<void> dispose() async => isActiveStream.close();
}

/// Real ChannelFactory handing out real MockWSChannels (same mock nostr's
/// own relays_monitor_test.dart uses), keyed by url so a test can fetch the
/// channel for a specific relay back out.
final class _FakeChannelFactory implements ChannelFactory {
  final channels = <String, MockWSChannel>{};

  @override
  WsChannel create(String url) =>
      channels.putIfAbsent(url, () => MockWSChannel(url: url));
}

/// Without this, pushing a canned response into a mock channel would pass
/// even if nothing underneath ever actually sent a probe — see nostr's own
/// relays_monitor_test.dart for the same reasoning.
bool _reqWasSent(MockWSChannel channel) => channel.calls.any(
  (c) => c.key == 'add' && (c.value as String).contains('"REQ"'),
);

void main() {
  group('RelaysMonitoringUsecaseImpl', () {
    const relayUrl = 'wss://relay1.example.com';

    late NostrClient client;
    late _FakeChannelFactory channelFactory;
    late _FakeAppLifecycleListenerRepository lifecycle;
    late RelaysMonitor monitor;
    late RelaysMonitoringUsecaseImpl sut;
    late StreamSubscription clientSub;

    setUp(() {
      channelFactory = _FakeChannelFactory();
      client = NostrClient(channelFactory: channelFactory);
      clientSub = client.stream().listen((_) {});
      monitor = RelaysMonitor(client: client);
      lifecycle = _FakeAppLifecycleListenerRepository();
      sut = RelaysMonitoringUsecaseImpl(monitor: monitor, lifecycle: lifecycle);
    });

    tearDown(() async {
      await clientSub.cancel();
      await sut.dispose();
      await client.disconnectAndDispose();
    });

    test("exposes the underlying RelaysMonitor's statuses", () async {
      client.addRelay(relayUrl);

      final statuses = await sut.statuses.firstWhere(
        (s) => s.containsKey(relayUrl),
      );

      expect(statuses, {relayUrl: RelayStatus.warning});
    });

    test(
      'backgrounding the app pauses the ticker; foregrounding resumes it',
      () {
        FakeAsync().run((async) {
          client.addRelay(relayUrl);
          async.flushMicrotasks();
          final channel = channelFactory.channels[relayUrl]!;
          expect(
            _reqWasSent(channel),
            isTrue,
            reason: 'sanity check: adding a relay should start the ticker',
          );
          channel.calls.clear();

          lifecycle.isActiveStream.add(false);
          async.flushMicrotasks();
          expect(
            _reqWasSent(channel),
            isFalse,
            reason: 'app in background: the ticker should be paused',
          );

          lifecycle.isActiveStream.add(true);
          async.flushMicrotasks();
          expect(
            _reqWasSent(channel),
            isTrue,
            reason: 'app back in foreground: the ticker should resume',
          );
        });
      },
    );

    test(
      'dispose() cancels the lifecycle subscription and disposes the monitor',
      () async {
        client.addRelay(relayUrl);
        await sut.statuses.first;
        expect(identical(client.delegate, monitor), isTrue);

        await sut.dispose();

        expect(client.delegate, isNull);
        // The lifecycle subscription must be gone too — this would throw
        // if a background/foreground event still reached a disposed
        // RelaysMonitor after dispose().
        expect(() => lifecycle.isActiveStream.add(false), returnsNormally);
      },
    );
  });
}
