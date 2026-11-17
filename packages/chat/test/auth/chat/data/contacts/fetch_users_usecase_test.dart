import 'dart:async';

import 'package:chat/auth/chat/data/contacts/fetch_users_usecase_impl.dart';
import 'package:chat/auth/chat/data/contacts/get_user_usecase_impl.dart';
import 'package:common/domain/model/user.dart';
import 'package:common/domain/repo/relays_list_repo.dart';
import 'package:common/services/event_store/database/app_database.dart';
import 'package:common/services/event_store/database/daos/nostr_event_dao.dart';
import 'package:common/services/event_store/drift_event_store.dart';
import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr/model/user_keys.dart';
import 'package:nostr/nostr_client/nostr_client.dart';

import '../../../../tools/nostr/direct_message_fixtures.dart';
import '../../../../tools/nostr/fake_relay.dart';

final class _FakeRelaysListRepo implements RelaysListRepo {
  @override
  Set<String> getRelaysList() => {FakeRelay.url};

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late AppDatabase db;
  late FakeRelay relay;
  late NostrClient client;
  late FetchUsersUsecaseImpl fetchUsers;
  late GetUserUseCaseImpl getUser;
  late UserKeys alice;

  setUp(() {
    db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
    final store = DriftEventStore(dao: NostrEventDao(db));
    relay = FakeRelay();
    client = NostrClient(channelFactory: relay.channelFactory);
    fetchUsers = FetchUsersUsecaseImpl(
      eventStore: store,
      client: client,
      relaysListRepo: _FakeRelaysListRepo(),
    );
    getUser = GetUserUseCaseImpl(eventStore: store);
    alice = generateKeys();

    addTearDown(() async {
      await client.disconnectAndDispose();
      await db.close();
    });
  });

  Future<User> storedAliceNamed(String name) {
    return getUser
        .execute(pubkey: alice.publicKey)
        .firstWhere((user) => user.name == name)
        .timeout(const Duration(seconds: 5));
  }

  StreamSubscription<void> subscribeToAlice() {
    final subscription = fetchUsers
        .execute(pubkeys: {alice.publicKey})
        .listen(null);
    addTearDown(subscription.cancel);
    return subscription;
  }

  test('stores the profile the relay already has', () async {
    relay.publish(profileEvent(of: alice, name: 'Alice'));

    subscribeToAlice();

    expect((await storedAliceNamed('Alice')).pubkey, alice.publicKey);
  });

  test('stores a profile published while subscribed', () async {
    relay.publish(profileEvent(of: alice, name: 'Alice'));
    subscribeToAlice();
    await storedAliceNamed('Alice');

    relay.publish(
      profileEvent(
        of: alice,
        name: 'Alicia',
        createdAt: DateTime.now().add(const Duration(minutes: 1)),
      ),
    );

    expect((await storedAliceNamed('Alicia')).name, 'Alicia');
  });

  test('an older profile does not replace the stored one', () async {
    relay.publish(profileEvent(of: alice, name: 'Alice'));
    subscribeToAlice();
    await storedAliceNamed('Alice');

    relay.publish(
      profileEvent(
        of: alice,
        name: 'Old Alice',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final stored = await getUser.execute(pubkey: alice.publicKey).first;
    expect(stored.name, 'Alice');
  });

  test('cancelling closes the subscription on the relay', () async {
    relay.publish(profileEvent(of: alice, name: 'Alice'));
    final subscription = subscribeToAlice();
    await storedAliceNamed('Alice');
    expect(relay.openSubscriptions, 1);

    await subscription.cancel();
    await Future<void>.delayed(Duration.zero);

    expect(relay.openSubscriptions, 0);
  });

  test('no pubkeys, no request', () async {
    await fetchUsers.execute(pubkeys: {}).toList();

    expect(relay.openSubscriptions, 0);
  });
}
