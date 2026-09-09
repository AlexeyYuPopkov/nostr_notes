import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nostr/model/nostr_filter.dart';
import 'package:nostr/model/nostr_req.dart';
import 'package:nostr/model/relay_health.dart';
import 'package:nostr/nostr_client/channel_factory.dart';
import 'package:nostr/nostr_client/nostr_client.dart';
import 'package:nostr/nostr_client/relays_monitor.dart';

import '../mocks/mock_wschannel.dart';

class MockChannelFactory extends Mock implements ChannelFactory {}

/// True once [channel] has actually been sent a Nostr "REQ" frame — without
/// this check, pushing a canned EOSE/event straight into a mock channel
/// would make a test pass even if RelaysMonitor's ticker never probed
/// anything.
bool _reqWasSent(MockWSChannel channel) => channel.calls.any(
  (c) => c.key == 'add' && (c.value as String).contains('"REQ"'),
);

/// Answers the first REQ sent to [channel] with a bare EOSE. RelaysMonitor
/// doesn't match on subscription id (onRelayActivity fires for any event
/// from that relay), so there's no need to echo the real one back.
void _respondToNextReqWithEose(MockWSChannel channel) {
  channel.onAdd = (data, ch) {
    if (data is String && data.contains('"REQ"')) {
      ch.mockStream.add('["EOSE","probe"]');
    }
  };
}

void main() {
  group('RelaysMonitor', () {
    const relayUrl1 = 'wss://relay1.example.com';
    const relayUrl2 = 'wss://relay2.example.com';

    late NostrClient client;
    late MockChannelFactory channelFactory;
    late MockWSChannel channel1;
    late MockWSChannel channel2;
    late RelaysMonitor sut;
    late StreamSubscription clientSub;

    setUp(() {
      channelFactory = MockChannelFactory();
      channel1 = MockWSChannel(url: relayUrl1);
      channel2 = MockWSChannel(url: relayUrl2);
      when(() => channelFactory.create(relayUrl1)).thenReturn(channel1);
      when(() => channelFactory.create(relayUrl2)).thenReturn(channel2);

      client = NostrClient(channelFactory: channelFactory);
      sut = RelaysMonitor(client: client);

      // RelaysMonitor only sees live signals (onRelayActivity/onRelayError)
      // while something is subscribed to client.stream() — same as the
      // app's own NotesRepositoryImpl.eventsStream keeping it alive.
      clientSub = client.stream().listen((_) {});
    });

    tearDown(() async {
      await clientSub.cancel();
      await sut.dispose();
      await client.disconnectAndDispose();
    });

    test(
      'a newly-added relay starts out as warning (not yet confirmed)',
      () async {
        client.addRelay(relayUrl1);

        // Not sut.statuses.first: that races the BehaviorSubject's own
        // replay-on-subscribe against _onRelaysChanged's reaction to
        // addRelay() — both go through the microtask queue, so a bare
        // .first can win the race and observe the seeded {} instead.
        final statuses = await sut.statuses.firstWhere(
          (s) => s.containsKey(relayUrl1),
        );

        expect(statuses, {relayUrl1: RelayStatus.warning});
      },
    );

    test('the ticker actually probes a newly-added relay', () async {
      client.addRelay(relayUrl1);
      await sut.statuses.firstWhere((s) => s.containsKey(relayUrl1));

      expect(_reqWasSent(channel1), isTrue);
    });

    test('receiving data from a relay marks it connected', () async {
      _respondToNextReqWithEose(channel1);
      client.addRelay(relayUrl1);

      final statuses = await sut.statuses.firstWhere(
        (s) => s[relayUrl1] == RelayStatus.connected,
      );

      expect(_reqWasSent(channel1), isTrue);
      expect(statuses[relayUrl1], RelayStatus.connected);
    });

    test('an error on a relay marks it disconnected', () async {
      client.addRelay(relayUrl1);
      await sut.statuses.first;

      final disconnected = sut.statuses.firstWhere(
        (s) => s[relayUrl1] == RelayStatus.disconnected,
      );
      // A transport-level failure, unlike a probe response, can happen
      // whether or not a REQ is in flight — no _reqWasSent gate needed.
      channel1.mockStream.addError(Exception('boom'));

      final statuses = await disconnected;
      expect(statuses[relayUrl1], RelayStatus.disconnected);
    });

    test('a later live signal overrides an earlier one', () async {
      _respondToNextReqWithEose(channel1);
      client.addRelay(relayUrl1);

      final connected = await sut.statuses.firstWhere(
        (s) => s[relayUrl1] == RelayStatus.connected,
      );
      expect(connected[relayUrl1], RelayStatus.connected);

      final disconnected = sut.statuses.firstWhere(
        (s) => s[relayUrl1] == RelayStatus.disconnected,
      );
      channel1.mockStream.addError(Exception('dropped'));

      final statuses = await disconnected;
      expect(statuses[relayUrl1], RelayStatus.disconnected);
    });

    test('removing a relay drops it from statuses', () async {
      client.addRelay(relayUrl1);
      client.addRelay(relayUrl2);
      await sut.statuses.firstWhere((s) => s.length == 2);

      final oneLeft = sut.statuses.firstWhere((s) => s.length == 1);
      await client.removeRelay(relayUrl1);

      final statuses = await oneLeft;
      expect(statuses, {relayUrl2: RelayStatus.warning});
    });

    test('pause() stops the ticker, but a live (non-probe) signal still '
        'updates status', () async {
      client.addRelay(relayUrl1);
      await sut.statuses.first;

      sut.pause();
      channel1.calls.clear(); // only care about traffic sent after pause()

      // Simulates the relay pushing something unprompted — a live signal
      // reaching NostrClientDelegate that has nothing to do with the
      // (now-stopped) ticker.
      final connected = sut.statuses.firstWhere(
        (s) => s[relayUrl1] == RelayStatus.connected,
      );
      channel1.mockStream.add('["EOSE","unsolicited"]');

      final statuses = await connected;
      expect(statuses[relayUrl1], RelayStatus.connected);
      expect(
        _reqWasSent(channel1),
        isFalse,
        reason: 'pause() should have stopped the ticker from probing',
      );

      // Shouldn't throw, whichever order these end up called in.
      sut.resume();
      sut.resume();
      sut.pause();
    });

    test(
      'a failed send marks the relay disconnected, without waiting for a tick',
      () async {
        _respondToNextReqWithEose(channel1);
        client.addRelay(relayUrl1);
        await sut.statuses.firstWhere(
          (s) => s[relayUrl1] == RelayStatus.connected,
        );

        // Network drops with the socket still nominally open: writes stop
        // landing, and nothing ever comes back in to report it.
        channel1.onAdd = (_, _) => throw Exception('offline');
        client.sendRequestToAll(
          const NostrReq(
            filters: [
              NostrFilter(kinds: [30023]),
            ],
          ),
        );

        await expectLater(
          sut.statuses.map((s) => s[relayUrl1]),
          emitsThrough(RelayStatus.disconnected),
        );
      },
    );

    test(
      'dispose() closes statuses and detaches the client delegate',
      () async {
        client.addRelay(relayUrl1);
        await sut.statuses.first;
        expect(identical(client.delegate, sut), isTrue);

        await sut.dispose();

        expect(client.delegate, isNull);
        // A closed BehaviorSubject still replays its last cached value to a
        // new subscriber before the done event — emitsDone alone expects
        // done to be the *first* thing observed, so it'd reject that replay.
        await expectLater(sut.statuses, emitsThrough(emitsDone));
      },
    );
  });
}
