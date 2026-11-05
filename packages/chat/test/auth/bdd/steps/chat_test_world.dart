import 'dart:async';

import 'package:chat/common/domain/models/session.dart';
import 'package:chat/common/domain/usecase/session_usecase.dart';
import 'package:common/domain/repo/relays_list_repo.dart';
import 'package:common/services/event_store/database/app_database.dart';
import 'package:common/services/outbox/outbox_publisher.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nostr/model/user_keys.dart';
import 'package:nostr/nostr_client/nostr_client.dart';

import '../../../tools/nostr/direct_message_fixtures.dart';
import '../../../tools/nostr/fake_relay.dart';

class _MockConnectivity extends Mock implements Connectivity {}

/// The signed-in user, their contacts and the one relay they all use.
/// The real auth scope runs on top: in-memory database, real crypto, relay
/// traffic through [relay].
///
/// Disposal is not awaited: once the test body ends, fake time no longer
/// advances, so waiting on drift or a relay socket to close never returns.
/// Features end with `After: I close the app` to unmount while it still does.
final class ChatTestWorld {
  static ChatTestWorld? _current;

  static ChatTestWorld get current =>
      _current ?? (throw StateError('Given the user is signed in first'));

  final relay = FakeRelay();
  final me = generateKeys();
  final _contacts = <String, UserKeys>{};

  ChatTestWorld._();

  /// Call after the auth scope is registered.
  static Future<void> install() async {
    final world = _current = ChatTestWorld._();

    GetIt.I.unregister<AppDatabase>();
    GetIt.I.registerLazySingleton<AppDatabase>(
      () => AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory())),
      dispose: (db) => unawaited(db.close()),
    );
    GetIt.I.unregister<NostrClient>();
    GetIt.I.registerLazySingleton<NostrClient>(
      () => NostrClient(channelFactory: world.relay.channelFactory),
      dispose: (client) => unawaited(client.disconnectAndDispose()),
    );
    GetIt.I.unregister<OutboxPublisher>();
    GetIt.I.registerLazySingleton<OutboxPublisher>(
      () => OutboxPublisher(
        outboxDao: GetIt.I.get(),
        rawEventStore: GetIt.I.get(),
        relaysListRepo: GetIt.I.get(),
        client: GetIt.I.get(),
        connectivity: GetIt.I.get(),
      ),
      dispose: (publisher) => unawaited(publisher.dispose()),
    );
    final connectivity = _MockConnectivity();
    when(
      () => connectivity.onConnectivityChanged,
    ).thenAnswer((_) => const Stream.empty());
    GetIt.I.unregister<Connectivity>();
    GetIt.I.registerSingleton<Connectivity>(connectivity);

    await GetIt.I.get<SessionUsecase>().setSession(Session.auth(world.me));
    await GetIt.I.get<RelaysListRepo>().saveRelaysList({FakeRelay.url});
  }

  static void uninstall() => _current = null;

  /// Drift binds a database to the zone that opens it; one opened under fake
  /// time stalls on its first write lock (seen with drift 2.35).
  static Future<void> openDatabase() async {
    await GetIt.I.get<AppDatabase>().customSelect('SELECT 1').get();
  }

  /// A contact with a kind 0 [name] on the relay, created on first mention.
  UserKeys contact(String name) {
    return _contacts.putIfAbsent(name, () {
      final keys = generateKeys();
      relay.publish(profileEvent(of: keys, name: name));
      return keys;
    });
  }
}
