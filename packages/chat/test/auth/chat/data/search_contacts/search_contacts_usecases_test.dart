import 'dart:convert';

import 'package:chat/auth/chat/data/search_contacts/search_contacts_fetch_usecase_impl.dart';
import 'package:chat/auth/chat/data/search_contacts/search_contacts_get_usecase_impl.dart';
import 'package:chat/auth/chat/data/search_contacts/search_contacts_helper.dart';
import 'package:common/domain/model/user.dart';
import 'package:common/domain/repo/relays_list_repo.dart';
import 'package:common/services/event_store/database/app_database.dart';
import 'package:common/services/event_store/database/daos/nostr_event_dao.dart';
import 'package:common/services/event_store/drift_event_store.dart';
import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nostr/key_tool/key_tool.dart';
import 'package:nostr/nostr_client/async_fetcher.dart';
import 'package:nostr/nostr_client/channel_factory.dart';
import 'package:nostr/nostr_client/nostr_client.dart';
import 'package:uuid/uuid.dart';

import '../../../../tools/nostr/fake_ws_channel.dart';

class _MockChannelFactory extends Mock implements ChannelFactory {}

class _MockUuid extends Mock implements Uuid {}

final class _FakeRelaysListRepo implements RelaysListRepo {
  @override
  Set<String> getRelaysList() => {_relayUrl};

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _Helper with SearchContactsHelper {
  const _Helper();
}

const _relayUrl = 'ws://relay.test';
const _subscriptionId = 'sub-id';
const _alicePubkey =
    '82341f882b6eabcd2ba7f1ef90aad961cf074af15b9ef44a09f9d2a8fbfbe6a2';
const _unknownPubkey =
    '3bf0c63fcb93463407af97a5e5ee64fa883d107ef9e558472c4eb9aaaefa459d';

String _profileFrame({required String pubkey, required String name}) {
  final event = {
    'kind': 0,
    'id': 'profile-$pubkey',
    'pubkey': pubkey,
    'created_at': 1,
    'tags': <List<String>>[],
    'content': jsonEncode({'name': name}),
    'sig': 'sig',
  };
  return '["EVENT","$_subscriptionId",${jsonEncode(event)}]';
}

const _eoseFrame = '["EOSE","$_subscriptionId"]';

void main() {
  group('Search contacts: fetch fills the store, get reads it', () {
    late AppDatabase db;
    late NostrClient client;
    late FakeWsChannel relay;
    late SearchContactsFetchUsecaseImpl fetch;
    late SearchContactsGetUsecaseImpl get;

    setUp(() {
      db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
      relay = FakeWsChannel(url: _relayUrl);
      final channelFactory = _MockChannelFactory();
      when(() => channelFactory.create(_relayUrl)).thenReturn(relay);
      final uuid = _MockUuid();
      when(uuid.v4).thenReturn(_subscriptionId);
      client = NostrClient(channelFactory: channelFactory, uuid: uuid);

      final store = DriftEventStore(dao: NostrEventDao(db));
      fetch = SearchContactsFetchUsecaseImpl(
        client: client,
        asyncFetcher: AsyncFetcher(client: client),
        relaysListRepo: _FakeRelaysListRepo(),
        eventStore: store,
      );
      get = SearchContactsGetUsecaseImpl(eventStore: store);
    });

    tearDown(() async {
      await client.disconnectAndDispose();
      await db.close();
    });

    void relayAnswers(List<String> frames) {
      relay.onSend = (frame, channel) {
        if (frame.contains('"REQ"')) {
          Future.microtask(() => frames.forEach(channel.receive));
        }
      };
    }

    test('a profile found by name on the relay reaches the store', () async {
      relayAnswers([
        _profileFrame(pubkey: _alicePubkey, name: 'Alice'),
        _eoseFrame,
      ]);
      final users = get.execute('ali');

      await fetch.execute('ali');

      await expectLater(
        users,
        emitsThrough(
          predicate<List<User>>(
            (list) => list.length == 1 && list.single.name == 'Alice',
          ),
        ),
      );
    });

    test('a stored profile is served without asking relays again', () async {
      relayAnswers([
        _profileFrame(pubkey: _alicePubkey, name: 'Alice'),
        _eoseFrame,
      ]);
      await fetch.execute('ali');
      relay.onSend = null;

      final users = await get.execute('ALI ').first;

      expect(users.single.name, 'Alice');
    });

    test('a profile is found by npub', () async {
      relayAnswers([
        _profileFrame(pubkey: _alicePubkey, name: 'Alice'),
        _eoseFrame,
      ]);
      final npub = KeyTool.npubKey(_alicePubkey);

      await fetch.execute(npub);
      final users = await get.execute(npub).first;

      expect(users.single.name, 'Alice');
    });

    test('a valid key without a profile is offered as a bare user', () async {
      relayAnswers([_eoseFrame]);

      await fetch.execute(_unknownPubkey);
      final users = await get.execute(_unknownPubkey).first;

      expect(users, [const User(pubkey: _unknownPubkey)]);
    });

    test('nothing matches', () async {
      relayAnswers([_eoseFrame]);

      await fetch.execute('nobody');
      final users = await get.execute('nobody').first;

      expect(users, isEmpty);
    });

    test('a blank query neither asks relays nor matches anything', () async {
      var requests = 0;
      relay.onSend = (frame, _) => requests++;

      await fetch.execute('  ');
      final users = await get.execute('  ').first;

      expect(requests, 0);
      expect(users, isEmpty);
    });
  });

  group('SearchContactsHelper.tryParsePubkey', () {
    const helper = _Helper();

    test('decodes an npub to its hex pubkey', () {
      expect(
        helper.tryParsePubkey(KeyTool.npubKey(_alicePubkey)),
        _alicePubkey,
      );
    });

    test('accepts a 64-char hex pubkey as is', () {
      expect(helper.tryParsePubkey(_alicePubkey), _alicePubkey);
    });

    test('treats plain text as a full-text query', () {
      expect(helper.tryParsePubkey('alice'), isNull);
    });

    test('rejects a malformed npub', () {
      expect(helper.tryParsePubkey('npub1garbage'), isNull);
    });

    test('rejects hex of the wrong length', () {
      expect(helper.tryParsePubkey(_alicePubkey.substring(1)), isNull);
    });
  });
}
