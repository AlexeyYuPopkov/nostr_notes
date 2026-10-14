import 'dart:async';

import 'package:common/services/event_store/database/app_database.dart';
import 'package:common/services/event_store/database/daos/outbox_dao_interface.dart';
import 'package:common/services/event_store/raw_event_store.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:di_storage/di_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr/nostr_client/channel_factory.dart';
import 'package:nostr/nostr_client/nostr_client.dart';
import 'package:nostr/nostr_client/nostr_event_creator.dart';
import 'package:nostr/nostr_client/ws_channel.dart';
import 'package:nostr_notes/services/outbox_publisher.dart';
import 'package:rxdart/rxdart.dart';

import '../../integration_test/di/in_memory_db_module.dart';
import '../tools/mocks/mock_relays_list_repo.dart';
import '../tools/some_moked_data.dart';

/// Longer than NostrPublisher's default 2s window: a cold WebSocket connect on
/// a mobile network or in a browser often takes this long.
const _coldConnect = Duration(milliseconds: 2500);

/// A relay that accepts every event, but only after its first send has waited
/// out the connection handshake — like [WsChannel.add] awaiting `ready`.
final class _ColdRelayChannel implements WsChannel {
  _ColdRelayChannel(this.url);

  @override
  final String url;

  final _incoming = PublishSubject<String>();
  bool _isConnected = false;

  @override
  Stream<dynamic> get stream => _incoming;

  @override
  Future<void> add(dynamic data) async {
    if (!_isConnected) {
      await Future<void>.delayed(_coldConnect);
      _isConnected = true;
    }
    final eventId = RegExp(r'"id":"([0-9a-f]+)"').firstMatch('$data')!.group(1);
    _incoming.add('["OK","$eventId",true,""]');
  }

  @override
  Future<void> disconnect() => _incoming.close();
}

final class _ColdRelayFactory implements ChannelFactory {
  int connections = 0;

  @override
  WsChannel create(String url) {
    connections++;
    return _ColdRelayChannel(url);
  }
}

final class _NoConnectivityChanges implements Connectivity {
  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => [
    ConnectivityResult.wifi,
  ];

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      const Stream.empty();
}

void main() {
  late OutboxDaoInterface outboxDao;
  late RawEventStore eventStore;
  late _ColdRelayFactory channelFactory;
  late NostrClient client;
  late OutboxPublisher sut;
  var createdAtSeconds = 0;

  Future<String> enqueueNote() async {
    final event = const NostrEventCreator().createEvent(
      kind: 1,
      content: 'note',
      createdAt: DateTime.fromMillisecondsSinceEpoch(++createdAtSeconds * 1000),
      tags: const [],
      pubkey: SomeMokedData.publicKey,
      privateKey: SomeMokedData.privateKey,
    );
    await eventStore.upsert([event]);
    await outboxDao.insert(eventId: event.id);
    return event.id;
  }

  Future<void> waitUntilOutboxIsEmpty() async {
    final deadline = DateTime.now().add(const Duration(seconds: 6));
    while (DateTime.now().isBefore(deadline)) {
      if ((await outboxDao.getPending()).isEmpty) return;
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
  }

  setUp(() {
    final di = DiStorage.shared;
    const InMemoryDbModule().bind(di);
    outboxDao = di.resolve();
    eventStore = di.resolve();
    channelFactory = _ColdRelayFactory();
    client = NostrClient(channelFactory: channelFactory);
    sut = OutboxPublisher(
      outboxDao: outboxDao,
      rawEventStore: eventStore,
      relaysListRepo: MockRelaysListRepo.withRelays({
        MockRelaysListRepo.relayUrl1,
      }),
      client: client,
      connectivity: _NoConnectivityChanges(),
    );
  });

  tearDown(() async {
    await sut.dispose();
    await client.disconnectAndDispose();
    final AppDatabase db = DiStorage.shared.resolve();
    await db.close();
    DiStorage.shared.removeAll();
  });

  test(
    'delivers an event when the relay answers only after a cold connect',
    () async {
      await sut.init();
      await enqueueNote();

      await waitUntilOutboxIsEmpty();

      expect(await outboxDao.getPending(), isEmpty);
    },
  );

  test('keeps one relay connection across published events', () async {
    await sut.init();
    await enqueueNote();
    await waitUntilOutboxIsEmpty();

    await enqueueNote();
    await waitUntilOutboxIsEmpty();

    expect(await outboxDao.getPending(), isEmpty);
    expect(channelFactory.connections, 1);
  });
}
