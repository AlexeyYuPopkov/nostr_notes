import 'dart:convert';

import 'package:common/services/event_store/database/app_database.dart';
import 'package:common/services/event_store/raw_event_store.dart';
import 'package:di_storage/di_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nostr/model/nostr_event.dart';
import 'package:nostr/nostr_client/async_fetcher.dart';
import 'package:nostr/nostr_client/channel_factory.dart';
import 'package:nostr/nostr_client/nostr_client.dart';
import 'package:nostr_notes/common/data/usecases/get_user_usecase_impl.dart';
import 'package:nostr_notes/common/domain/usecase/get_user_usecase.dart';
import 'package:uuid/uuid.dart';

import '../../../../integration_test/di/in_memory_db_module.dart';
import '../../../tools/mock_wschannel.dart';

class _MockChannelFactory extends Mock implements ChannelFactory {}

class _MockUuid extends Mock implements Uuid {}

const _relayUrl = 'ws://relay.test';
const _pubkey =
    'a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2';

NostrEvent _metadataEvent({
  required String id,
  required int createdAt,
  required Map<String, dynamic> profile,
}) {
  return NostrEvent(
    kind: 0,
    id: id,
    pubkey: _pubkey,
    createdAt: createdAt,
    tags: const [],
    content: jsonEncode(profile),
    sig: 'sig-$id',
  );
}

String _eventJson(String subscriptionId, NostrEvent event) {
  return '["EVENT","$subscriptionId",${jsonEncode(event.toJson())}]';
}

String _eoseJson(String subscriptionId) => '["EOSE","$subscriptionId"]';

void main() {
  group('GetUserUsecase', () {
    late _MockChannelFactory channelFactory;
    late _MockUuid uuid;
    late NostrClient client;
    late RawEventStore eventStore;
    late GetUserUsecase sut;

    setUp(() {
      final di = DiStorage.shared;
      const InMemoryDbModule().bind(di);
      eventStore = di.resolve<RawEventStore>();

      channelFactory = _MockChannelFactory();
      uuid = _MockUuid();
      client = NostrClient(channelFactory: channelFactory, uuid: uuid);

      sut = GetUserUsecaseImpl(
        asyncFetcher: AsyncFetcher(client: client),
        rawEventStore: eventStore,
      );

      when(() => uuid.v4()).thenReturn('sub-id');
    });

    tearDown(() async {
      await client.disconnectAndDispose();
      final AppDatabase db = DiStorage.shared.resolve();
      await db.close();
      DiStorage.shared.removeAll();
    });

    test(
      'returns null when there is no local data and no relay configured',
      () async {
        final result = await sut.execute(pubkey: _pubkey).first;

        expect(result, isNull);
      },
    );

    test(
      'fetches user from relay and stores it when there is no local event',
      () async {
        final channel = MockWSChannel(url: _relayUrl);
        when(() => channelFactory.create(_relayUrl)).thenReturn(channel);
        client.addRelay(_relayUrl);

        final remoteEvent = _metadataEvent(
          id: 'remote-event-id',
          createdAt: 1000,
          profile: const {'name': 'alice', 'display_name': 'Alice A'},
        );

        channel.onAdd = (data, ch) {
          if ((data as String).contains('"REQ"')) {
            Future.microtask(() {
              ch.mockStream.add(_eventJson('sub-id', remoteEvent));
              ch.mockStream.add(_eoseJson('sub-id'));
            });
          }
        };

        final result = await sut
            .execute(pubkey: _pubkey)
            .where((user) => user != null)
            .first;

        expect(result, isNotNull);
        expect(result!.pubkey, _pubkey);
        expect(result.name, 'alice');
        expect(result.displayName, 'Alice A');

        final stored = await eventStore.queryEvents(
          const RawEventQuery(authors: [_pubkey], kinds: [0]),
        );
        expect(stored, hasLength(1));
        expect(stored.first.id, 'remote-event-id');
      },
    );

    test(
      'returns cached user on a second call without querying the relay again',
      () async {
        final channel = MockWSChannel(url: _relayUrl);
        when(() => channelFactory.create(_relayUrl)).thenReturn(channel);
        client.addRelay(_relayUrl);

        final remoteEvent = _metadataEvent(
          id: 'remote-event-id',
          createdAt: 1000,
          profile: const {'name': 'alice'},
        );

        channel.onAdd = (data, ch) {
          if ((data as String).contains('"REQ"')) {
            Future.microtask(() {
              ch.mockStream.add(_eventJson('sub-id', remoteEvent));
              ch.mockStream.add(_eoseJson('sub-id'));
            });
          }
        };

        final first = await sut
            .execute(pubkey: _pubkey)
            .where((user) => user != null)
            .first;

        expect(first!.name, 'alice');

        final requestsBeforeSecondCall = channel.calls
            .where(
              (c) => c.key == 'add' && (c.value as String).contains('"REQ"'),
            )
            .length;

        final second = await sut
            .execute(pubkey: _pubkey)
            .where((user) => user != null)
            .first;

        expect(second, equals(first));

        final requestsAfterSecondCall = channel.calls
            .where(
              (c) => c.key == 'add' && (c.value as String).contains('"REQ"'),
            )
            .length;
        expect(requestsAfterSecondCall, requestsBeforeSecondCall);
      },
    );

    test(
      'keeps the local user when the relay only returns an older event',
      () async {
        final localEvent = _metadataEvent(
          id: 'local-event-id',
          createdAt: 2000,
          profile: const {'name': 'newer-local'},
        );
        await eventStore.upsert([localEvent]);

        final channel = MockWSChannel(url: _relayUrl);
        when(() => channelFactory.create(_relayUrl)).thenReturn(channel);
        client.addRelay(_relayUrl);

        final olderRemoteEvent = _metadataEvent(
          id: 'older-remote-event-id',
          createdAt: 1000,
          profile: const {'name': 'older-remote'},
        );

        channel.onAdd = (data, ch) {
          if ((data as String).contains('"REQ"')) {
            Future.microtask(() {
              ch.mockStream.add(_eventJson('sub-id', olderRemoteEvent));
              ch.mockStream.add(_eoseJson('sub-id'));
            });
          }
        };

        final result = await sut.execute(pubkey: _pubkey).first;

        expect(result!.name, 'newer-local');

        final stored = await eventStore.queryEvents(
          const RawEventQuery(authors: [_pubkey], kinds: [0]),
        );
        expect(stored, hasLength(1));
        expect(stored.first.id, 'local-event-id');
      },
    );

    test(
      'updates the stored user when the relay returns a newer event',
      () async {
        final localEvent = _metadataEvent(
          id: 'local-event-id',
          createdAt: 1000,
          profile: const {'name': 'older-local'},
        );
        await eventStore.upsert([localEvent]);

        final channel = MockWSChannel(url: _relayUrl);
        when(() => channelFactory.create(_relayUrl)).thenReturn(channel);
        client.addRelay(_relayUrl);

        final newerRemoteEvent = _metadataEvent(
          id: 'newer-remote-event-id',
          createdAt: 2000,
          profile: const {'name': 'newer-remote'},
        );

        channel.onAdd = (data, ch) {
          if ((data as String).contains('"REQ"')) {
            Future.microtask(() {
              ch.mockStream.add(_eventJson('sub-id', newerRemoteEvent));
              ch.mockStream.add(_eoseJson('sub-id'));
            });
          }
        };

        final result = sut
            .execute(pubkey: _pubkey)
            .map((user) {
              if (user != null) {
                return user.name;
              }
              return null;
            })
            .where((user) => user != null);

        await expectLater(
          result,
          emitsInOrder(['older-local', 'newer-remote']),
        );

        final stored = await eventStore.queryEvents(
          const RawEventQuery(authors: [_pubkey], kinds: [0]),
        );
        expect(stored, hasLength(1));
        expect(stored.first.id, 'newer-remote-event-id');
      },
    );
  });
}
