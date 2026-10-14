import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nostr/model/nostr_filter.dart';
import 'package:nostr/model/nostr_req.dart';
import 'package:nostr/nostr_client/channel_factory.dart';
import 'package:nostr/nostr_client/nostr_client.dart';
import 'package:nostr/nostr_client/nostr_client_delegate.dart';

import '../mocks/mock_wschannel.dart';

class _MockChannelFactory extends Mock implements ChannelFactory {}

final class _CountingDelegate implements NostrClientDelegate {
  int activity = 0;

  @override
  void onRelayActivity(String url) => activity++;

  @override
  void onRelayError(String url, Object error, StackTrace? stackTrace) {}
}

void main() {
  const relayUrl = 'wss://relay.example.com';
  const settle = Duration(milliseconds: 50);

  late MockWSChannel channel;
  late _CountingDelegate delegate;
  late NostrClient client;

  setUp(() async {
    channel = MockWSChannel(url: relayUrl);
    final factory = _MockChannelFactory();
    when(() => factory.create(relayUrl)).thenReturn(channel);
    delegate = _CountingDelegate();
    client = NostrClient(channelFactory: factory, delegate: delegate);
    client.addRelay(relayUrl);
    // Opens the relay connection, so pushed frames reach the relay.
    client.sendRequestToAll(
      const NostrReq(
        filters: [
          NostrFilter(kinds: [1], limit: 1),
        ],
      ),
    );
    await Future<void>.delayed(Duration.zero);
  });

  tearDown(() => client.disconnectAndDispose());

  test('a cancelled stream() stops listening to its relays', () async {
    final sub = client.stream().listen((_) {});
    channel.mockStream.add('["EOSE","while-listening"]');
    await Future<void>.delayed(settle);
    expect(delegate.activity, 1);

    await sub.cancel();
    channel.mockStream.add('["EOSE","after-cancel"]');
    await Future<void>.delayed(settle);

    expect(delegate.activity, 1);
  });

  test(
    'two listeners of one stream() share it until the last cancels',
    () async {
      final stream = client.stream();
      final first = stream.listen((_) {});
      final second = stream.listen((_) {});

      await first.cancel();
      channel.mockStream.add('["EOSE","one-left"]');
      await Future<void>.delayed(settle);
      expect(delegate.activity, 1);

      await second.cancel();
      channel.mockStream.add('["EOSE","none-left"]');
      await Future<void>.delayed(settle);
      expect(delegate.activity, 1);
    },
  );
}
