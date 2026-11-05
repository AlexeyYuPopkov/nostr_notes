import 'dart:convert';

import 'package:chat/auth/settings/data/profile/get_current_profile_usecase_impl.dart';
import 'package:chat/auth/settings/data/profile/update_profile_usecase_impl.dart';
import 'package:chat/auth/settings/domain/models/profile_exception.dart';
import 'package:chat/auth/settings/domain/models/profile_fields.dart';
import 'package:chat/common/domain/models/session.dart';
import 'package:chat/common/domain/usecase/session_usecase.dart';
import 'package:common/domain/model/user.dart';
import 'package:common/domain/repo/relays_list_repo.dart';
import 'package:common/services/event_store/database/app_database.dart';
import 'package:common/services/event_store/database/daos/nostr_event_dao.dart';
import 'package:common/services/event_store/drift_event_store.dart';
import 'package:common/services/event_store/raw_event_store.dart';
import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nostr/key_tool/key_tool.dart';
import 'package:nostr/model/nostr_event.dart';
import 'package:nostr/model/user_keys.dart';
import 'package:nostr/nostr_client/async_fetcher.dart';
import 'package:nostr/nostr_client/channel_factory.dart';
import 'package:nostr/nostr_client/nostr_client.dart';
import 'package:nostr/nostr_client/nostr_event_creator.dart';
import 'package:uuid/uuid.dart';

import '../../../../tools/nostr/fake_ws_channel.dart';

class _MockChannelFactory extends Mock implements ChannelFactory {}

class _MockUuid extends Mock implements Uuid {}

final class _FakeRelaysListRepo implements RelaysListRepo {
  Set<String> relays = {_relayUrl};

  @override
  Set<String> getRelaysList() => relays;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _relayUrl = 'ws://relay.test';
const _subscriptionId = 'sub-id';
const _shortPublishWindow = Duration(milliseconds: 200);

UserKeys _generateKeys() {
  final privateKey = KeyTool.random64HexChars();
  return UserKeys(
    publicKey: KeyTool.tryGetPubKey(privateKey: privateKey)!,
    privateKey: privateKey,
  );
}

NostrEvent _storedProfile({
  required String pubkey,
  required Map<String, Object?> content,
  required int createdAt,
  List<List<String>> tags = const [],
}) {
  return NostrEvent(
    kind: 0,
    id: 'stored-profile-$createdAt',
    pubkey: pubkey,
    createdAt: createdAt,
    tags: tags,
    content: jsonEncode(content),
    sig: 'sig',
  );
}

void main() {
  late AppDatabase db;
  late RawEventStore store;
  late NostrClient client;
  late FakeWsChannel relay;
  late _FakeRelaysListRepo relaysListRepo;
  late SessionUsecase sessionUsecase;
  late UserKeys keys;
  late List<String> publishedEventIds;

  setUp(() async {
    db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
    store = DriftEventStore(dao: NostrEventDao(db));
    relay = FakeWsChannel(url: _relayUrl);
    final channelFactory = _MockChannelFactory();
    when(() => channelFactory.create(_relayUrl)).thenReturn(relay);
    final uuid = _MockUuid();
    when(uuid.v4).thenReturn(_subscriptionId);
    client = NostrClient(channelFactory: channelFactory, uuid: uuid);
    relaysListRepo = _FakeRelaysListRepo();

    keys = _generateKeys();
    sessionUsecase = SessionUsecase();
    await sessionUsecase.setSession(Session.auth(keys));

    publishedEventIds = [];
  });

  tearDown(() async {
    await client.disconnectAndDispose();
    await sessionUsecase.dispose();
    await db.close();
  });

  /// The relay answers a REQ with [profiles] and accepts (or rejects) every
  /// published event.
  void relayBehaves({
    List<NostrEvent> profiles = const [],
    bool acceptsEvents = true,
  }) {
    relay.onSend = (frame, channel) {
      final message = jsonDecode(frame) as List<Object?>;
      switch (message.first) {
        case 'REQ':
          Future.microtask(() {
            for (final profile in profiles) {
              channel.receive(jsonEncode(['EVENT', _subscriptionId, profile]));
            }
            channel.receive(jsonEncode(['EOSE', _subscriptionId]));
          });
        case 'EVENT':
          final event = NostrEvent.fromJson(
            message[1]! as Map<String, dynamic>,
          );
          publishedEventIds.add(event.id);
          Future.microtask(
            () => channel.receive(
              jsonEncode(['OK', event.id, acceptsEvents, '']),
            ),
          );
      }
    };
  }

  GetCurrentProfileUsecaseImpl getUsecase() => GetCurrentProfileUsecaseImpl(
    sessionUsecase: sessionUsecase,
    eventStore: store,
    client: client,
    asyncFetcher: AsyncFetcher(client: client),
    relaysListRepo: relaysListRepo,
  );

  UpdateProfileUsecaseImpl updateUsecase({DateTime Function()? now}) =>
      UpdateProfileUsecaseImpl(
        sessionUsecase: sessionUsecase,
        eventStore: store,
        client: client,
        relaysListRepo: relaysListRepo,
        now: now ?? DateTime.now,
        publishWindow: _shortPublishWindow,
      );

  Future<NostrEvent> newestStoredProfile() async {
    final events = await store.queryEvents(
      RawEventQuery(kinds: const [0], authors: [keys.publicKey]),
    );
    return events.reduce((a, b) => a.createdAt >= b.createdAt ? a : b);
  }

  group('Current profile', () {
    test('is a bare user until the relay sends the stored profile', () {
      relayBehaves(
        profiles: [
          _storedProfile(
            pubkey: keys.publicKey,
            content: {'name': 'Alice'},
            createdAt: 1,
          ),
        ],
      );

      expect(
        getUsecase().execute(),
        emitsInOrder([
          User(pubkey: keys.publicKey),
          User(pubkey: keys.publicKey, name: 'Alice'),
        ]),
      );
    });

    test('shows what is stored even when no relay is configured', () async {
      relaysListRepo.relays = {};
      await store.upsert([
        _storedProfile(
          pubkey: keys.publicKey,
          content: {'name': 'Alice', 'display_name': 'Alice A.'},
          createdAt: 1,
        ),
      ]);

      expect(
        await getUsecase().execute().first,
        User(pubkey: keys.publicKey, name: 'Alice', displayName: 'Alice A.'),
      );
    });

    test('a saved profile reaches the stream', () async {
      relayBehaves();
      final profile = getUsecase().execute();

      await updateUsecase().execute(const ProfileFields(name: 'Bob'));

      expect(
        await profile.firstWhere((user) => user.name != null),
        User(pubkey: keys.publicKey, name: 'Bob'),
      );
    });
  });

  group('Saving the profile', () {
    test(
      'keeps the fields it does not edit and drops deprecated ones',
      () async {
        relayBehaves();
        await store.upsert([
          _storedProfile(
            pubkey: keys.publicKey,
            content: {
              'name': 'Alice',
              'about': 'Hi',
              'lud16': 'alice@example.com',
              'picture': 'https://example.com/old.jpg',
              'displayName': 'Old alias',
              'username': 'old_alias',
            },
            createdAt: 100,
            tags: [
              ['i', 'github:alice', 'proof'],
            ],
          ),
        ]);

        await updateUsecase().execute(
          const ProfileFields(name: ' Bob ', displayName: 'Bobby', picture: ''),
        );

        final event = await newestStoredProfile();
        expect(jsonDecode(event.content), {
          'name': 'Bob',
          'about': 'Hi',
          'lud16': 'alice@example.com',
          'display_name': 'Bobby',
        });
        expect(event.tags, [
          ['i', 'github:alice', 'proof'],
        ]);
        expect(event.kind, 0);
        expect(event.pubkey, keys.publicKey);
        expect(event.createdAt, greaterThan(100));
      },
    );

    test('signs the event and publishes it to the relay', () async {
      relayBehaves();

      await updateUsecase().execute(const ProfileFields(name: 'Bob'));

      final event = await newestStoredProfile();
      expect(
        event.id,
        const NostrEventCreator().createEventId(
          kind: event.kind,
          content: event.content,
          createdAt: event.createdAt,
          tags: event.tags,
          pubkey: event.pubkey,
        ),
      );
      expect(event.sig, isNotEmpty);
      expect(publishedEventIds, [event.id]);
    });

    test(
      'is newer than the stored profile even if the clock is behind',
      () async {
        relayBehaves();
        const storedCreatedAt = 2000000000;
        await store.upsert([
          _storedProfile(
            pubkey: keys.publicKey,
            content: {'name': 'Alice'},
            createdAt: storedCreatedAt,
          ),
        ]);

        await updateUsecase(
          now: () => DateTime.utc(2026),
        ).execute(const ProfileFields(name: 'Bob'));

        final event = await newestStoredProfile();
        expect(event.createdAt, storedCreatedAt + 1);
        expect(jsonDecode(event.content), {'name': 'Bob'});
      },
    );

    test('without relays the profile stays on the device', () async {
      relaysListRepo.relays = {};

      await expectLater(
        updateUsecase().execute(const ProfileFields(name: 'Bob')),
        throwsA(isA<ProfileNotPublishedException>()),
      );

      final event = await newestStoredProfile();
      expect(jsonDecode(event.content), {'name': 'Bob'});
    });

    test('a relay that rejects it is reported, the profile is kept', () async {
      relayBehaves(acceptsEvents: false);

      await expectLater(
        updateUsecase().execute(const ProfileFields(name: 'Bob')),
        throwsA(isA<ProfileNotPublishedException>()),
      );

      final event = await newestStoredProfile();
      expect(jsonDecode(event.content), {'name': 'Bob'});
    });

    test('without a session nothing is signed', () async {
      await sessionUsecase.setSession(const Session.unauth());

      await expectLater(
        updateUsecase().execute(const ProfileFields(name: 'Bob')),
        throwsA(isA<ProfileNoSessionException>()),
      );
    });
  });
}
