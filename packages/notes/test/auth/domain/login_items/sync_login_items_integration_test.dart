import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:common/services/event_store/database/app_database.dart';
import 'package:common/services/event_store/database/daos/outbox_dao_interface.dart';
import 'package:common/services/event_store/raw_event_store.dart';
import 'package:di_storage/di_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nostr/model/user_keys.dart';
import 'package:nostr/nostr_client/channel_factory.dart';
import 'package:nostr/nostr_client/nostr_client.dart';
import 'package:nostr_notes/auth/data/login_items/delete_login_item_usecase_impl.dart';
import 'package:nostr_notes/auth/data/login_items/get_login_item_usecase_impl.dart';
import 'package:nostr_notes/auth/data/login_items/login_item_crypto_usecase_impl.dart';
import 'package:nostr_notes/auth/data/login_items/save_login_item_usecase_impl.dart';
import 'package:nostr_notes/auth/data/login_items/sync_login_items_usecase_impl.dart';
import 'package:nostr_notes/auth/data/login_items/vault_identity_usecase_impl.dart';
import 'package:nostr_notes/auth/data/login_items/watch_login_items_usecase_impl.dart';
import 'package:nostr_notes/auth/domain/model/login_item.dart';
import 'package:nostr_notes/auth/domain/usecase/login_items/delete_login_item_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/login_items/sync_login_items_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/login_items/watch_login_items_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/note_crypto_use_case.dart';
import 'package:nostr_notes/common/domain/model/session/session.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';
import 'package:nostr_notes/services/crypto_service/crypto_service.dart';

import '../../../../integration_test/di/in_memory_db_module.dart';
import '../../../tools/mock_wschannel.dart';
import '../../../tools/mocks/mock_relays_list_repo.dart';

class MockChannelFactory extends Mock implements ChannelFactory {}

/// A real vault whose private key produces the exact vault pubkey the
/// fixture events below are authored by, and whose PIN is what their
/// content was NIP-44-encrypted with — so this test exercises genuine
/// decryption, not just a pipeline that tolerates locked items.
const _keys = UserKeys(
  publicKey: '8c78952169177d4fba467bee54029da5877ef4ffdaf10192baa74044a914df8f',
  privateKey:
      'd511ca0405176c93f5412c13b2f915b753ad5625c0db29fdf42a9cd2e66fa1ce',
);
const _pin = '270';

void main() {
  group('SyncLoginItemsIntegration', () {
    late NostrClient client;
    late MockChannelFactory channelFactory;
    late MockWSChannel channel;
    late SessionUsecase sessionUsecase;

    late SyncLoginItemsUsecase fetchSut;
    late WatchLoginItemsUsecase watchSut;
    late DeleteLoginItemUsecase deleteSut;
    late GetLoginItemUsecaseImpl getSut;
    late SaveLoginItemUsecaseImpl saveSut;

    StreamSubscription<List<dynamic>>? syncSubscription;
    StreamSubscription<List<LoginItem>>? watchSubscription;

    setUp(() async {
      final di = DiStorage.shared;
      const InMemoryDbModule().bind(di);

      channelFactory = MockChannelFactory();
      channel = MockWSChannel(url: MockRelaysListRepo.relayUrl1);
      client = NostrClient(channelFactory: channelFactory);

      when(
        () => channelFactory.create(MockRelaysListRepo.relayUrl1),
      ).thenReturn(channel);

      sessionUsecase = SessionUsecase();
      await sessionUsecase.setSession(
        const Session.unlocked(keys: _keys, pin: _pin),
      );

      final vaultIdentity = VaultIdentityUsecaseImpl(
        sessionUsecase: sessionUsecase,
      );

      final cryptoService = CryptoService.create(Uint8List(32));
      final loginItemCrypto = LoginItemCryptoUsecaseImpl(
        cryptoService: cryptoService,
        sessionUsecase: sessionUsecase,
        extraDerivation: ExtraDerivation(
          cryptoService: cryptoService,
          sessionUsecase: sessionUsecase,
        ),
      );

      final RawEventStore store = di.resolve();
      final OutboxDaoInterface outboxDao = di.resolve();

      fetchSut = SyncLoginItemsUsecaseImpl(
        client: client,
        eventStore: store,
        relaysListRepo: MockRelaysListRepo.withRelays({
          MockRelaysListRepo.relayUrl1,
        }),
        vaultIdentityUsecase: vaultIdentity,
      );
      watchSut = WatchLoginItemsUsecaseImpl(
        eventStore: store,
        vaultIdentityUsecase: vaultIdentity,
        loginItemCryptoUsecase: loginItemCrypto,
      );
      getSut = GetLoginItemUsecaseImpl(
        eventStore: store,
        vaultIdentityUsecase: vaultIdentity,
        loginItemCryptoUsecase: loginItemCrypto,
      );
      deleteSut = DeleteLoginItemUsecaseImpl(
        eventStore: store,
        outboxDao: outboxDao,
        vaultIdentityUsecase: vaultIdentity,
      );
      saveSut = SaveLoginItemUsecaseImpl(
        eventStore: store,
        outboxDao: outboxDao,
        vaultIdentityUsecase: vaultIdentity,
        loginItemCryptoUsecase: loginItemCrypto,
      );
    });

    tearDown(() async {
      await syncSubscription?.cancel();
      await watchSubscription?.cancel();
      await sessionUsecase.dispose();
      await client.disconnectAndDispose();
      await pumpEventQueue();
      final AppDatabase db = DiStorage.shared.resolve();
      await db.close();
      DiStorage.shared.removeAll();
    });

    test('sync ingests relay events into the store; watch/get see them; '
        'delete removes them and watch reacts', () async {
      final watchedEmissions = <List<LoginItem>>[];
      watchSubscription = watchSut.execute().listen(watchedEmissions.add);

      final syncedBatches = <List<dynamic>>[];
      syncSubscription = fetchSut.execute().listen(syncedBatches.add);

      // The "relay": echoes the fixture events back for every REQ it
      // receives.
      //
      // Deferred via a delay rather than pushed synchronously: `add` fires
      // inside NostrClient.sendRequestToAll's synchronous call chain,
      // before SyncLoginItemsUsecaseImpl's switchMap callback has even
      // returned its `_client.stream()` — i.e. before anything is
      // subscribed yet. A synchronous push into the (non-replaying)
      // broadcast stream at that point would be lost.
      channel.onAdd = (data, ch) {
        final decoded = jsonDecode(data as String) as List<dynamic>;
        if (decoded.first != 'REQ') return;
        final subscriptionId = decoded[1] as String;
        Future.delayed(const Duration(milliseconds: 10), () {
          for (final event in _Helper.rawEvents) {
            ch.mockStream.add(jsonEncode(['EVENT', subscriptionId, event]));
          }
        });
      };

      // Let the REQ reach the mock relay and the events arrive. rxdart's
      // bufferTime only opens its recurring 100ms window *after* the
      // first buffered event, and this test's watch stream is decrypting
      // real NIP-44 payloads via native FFI crypto concurrently — under
      // a debug build that's enough isolate-event-loop contention that
      // 100ms alone is unreliable; this margin is comfortably above what
      // was observed empirically.
      await Future.delayed(const Duration(milliseconds: 1500));

      expect(
        syncedBatches,
        isNotEmpty,
        reason: 'SyncLoginItemsUsecase should have emitted upserted events',
      );

      expect(
        watchedEmissions.last.map((e) => e.dTag).toSet(),
        _Helper.dTags.toSet(),
        reason:
            'WatchLoginItemsUsecase should reactively pick up the '
            'events synced into the store',
      );
      expect(
        watchedEmissions.last.every((e) => e.error == null),
        isTrue,
        reason:
            'the fixture content should genuinely decrypt, not just '
            'survive as locked items',
      );

      final target = watchedEmissions.last.firstWhere(
        (e) => e.title == 'amazon.com',
      );
      expect(target.username, 'alex');
      expect(target.password, 'qwertyu');

      final got = await getSut.execute(dTag: target.dTag);
      expect(got, isNotNull);
      expect(got!.dTag, target.dTag);
      expect(got.eventId, isNotEmpty);
      expect(got.title, 'amazon.com');

      await deleteSut.execute(item: got);

      expect(
        await getSut.execute(dTag: target.dTag),
        isNull,
        reason: 'GetLoginItemUsecase should no longer resolve a deleted dTag',
      );

      await Future.delayed(const Duration(milliseconds: 100));

      expect(
        watchedEmissions.last.map((e) => e.dTag),
        isNot(contains(target.dTag)),
        reason:
            'WatchLoginItemsUsecase should reactively drop the deleted '
            'item',
      );
      expect(watchedEmissions.last, hasLength(_Helper.dTags.length - 1));

      final saved = await saveSut.execute(
        item: LoginItem.draft(
          title: 'GitHub',
          username: 'octocat',
          password: 'hunter2',
          websiteUrl: 'https://github.com',
          notes: 'work account',
        ),
      );
      expect(saved.dTag, isNotEmpty);

      final gotSaved = await getSut.execute(dTag: saved.dTag);
      expect(
        gotSaved,
        isNotNull,
        reason: 'GetLoginItemUsecase should resolve the newly saved item',
      );
      expect(gotSaved!.title, 'GitHub');
      expect(gotSaved.username, 'octocat');
      expect(gotSaved.password, 'hunter2');

      await Future.delayed(const Duration(milliseconds: 100));

      expect(
        watchedEmissions.last.map((e) => e.dTag),
        contains(saved.dTag),
        reason:
            'WatchLoginItemsUsecase should reactively pick up the newly '
            'saved item',
      );
      expect(watchedEmissions.last, hasLength(_Helper.dTags.length));
    });
  });
}

/// Fixture login-item (kind 31023) events, as they'd arrive from a relay —
/// three distinct d-tags, deduplicated from what a real sync would receive
/// from multiple relays. Authored by the vault derived from [_keys], and
/// the `content` is real NIP-44 ciphertext encrypted under PIN [_pin] with
/// [PinKdf.current] — so this test's session genuinely decrypts them.
final class _Helper {
  static const rawEvents = [
    {
      'kind': 31023,
      'id': 'ed2c347d6bc7cf23cf531e21c041352cb08b016a7216c45db41889466471a880',
      'pubkey':
          'd02386c8255ae21c4ff24f1df5d7f630943e333f614eda317e73deedb7f2b7c3',
      'created_at': 1786275327,
      'tags': [
        ['d', 'b7af2c7c-88a3-4fee-97de-15a1de886fc6'],
      ],
      'content':
          'Ag6sxHyDq6SLu8nYlYMBc/AdaTWXW+GJcWfKZUA3AjBK/IcDF6QoEtQl9uVpByEBiJU+B0zg7DRpbdZjb7DOaWLf/7tTxtnbs/mtgvNW1gz9QE5uVGSXn6lR2aN5Wo9OsNn4ZUkYHSn51m+k35kRgnrrCCg2UjHKsW1D4iHNcaGnvWHNWloyjyE5iUE4haK+qPL/3enUkm3VNuNnwaMAXPFesYweDvVzTuljjkQPclch7PAhaT2nnJHQo5P8V+G80NVEynTTILlTlpZWwHgpqB21MeOpeomPv2X9JmklZyjztFQ=',
      'sig':
          'e5ed0c782c9917ee5e4d386b3c315f7df17b55026f9b0e2d18b215dfcee4f5a5be23e0ab76e203cf0d0bd65262ed187d6686346841645ea6707a7d5a49ffdda6',
    },
    {
      'kind': 31023,
      'id': '4f5e73bab536974fd7a7c6a8b6b76fd559b5b5e31315cc9a384d6a9b68d089d0',
      'pubkey':
          'd02386c8255ae21c4ff24f1df5d7f630943e333f614eda317e73deedb7f2b7c3',
      'created_at': 1786275287,
      'tags': [
        ['d', '30d5086c-6e55-4227-80d8-cd923f474d49'],
      ],
      'content':
          'AoDS2Jb88RzWK06nMoAAYI7xFXiOyBX9fRTnZcz/EiMb1IkDJ3zcdRtN2a+HKOpPBrQ+WH7eNtfWATNWpy4vxaoWBmRoZK1xOrnpIY39xk5wyrg7mk//TkAgKN2SU3+TLM0QBTrgub0uKDUPqceGw4NsHMwDRytRxxWkqzbZbXQ+qTKN69dX2cOUXX8R5+0T+c2mOxHoxaxRzH/vju9XgsnCapEPQi49aCuUYok+noxFi+hgZ56A3uiVUHzergcgcCnvfG2iWKfQvWawqDVLOXSuQ5gdJDwXYoPvPJ1bkcgjVOI=',
      'sig':
          'f4ea5e03144df96f8f4fcde5e5b6d6e127248b83a987f8371db4c841473194db55c9abf835b03fd38a5070b17ddc514d9afcf07bc2c70778eb0db7428c85a699',
    },
    {
      'kind': 31023,
      'id': 'ca3324f3d018d74474c0689885562890e3cb598a68f0555fcc2e9af6f46bb816',
      'pubkey':
          'd02386c8255ae21c4ff24f1df5d7f630943e333f614eda317e73deedb7f2b7c3',
      'created_at': 1786275237,
      'tags': [
        ['d', 'f5ea33c2-4184-4376-8994-ef5a3ff3b531'],
      ],
      'content':
          'AnL4NZrO5gj7iw7uzoqDUVVxkQ6tthJRUD5bKIKca5AAjPsiPkoxEwlVlfTAaxnljnyN80vyKvaDS7dSkrWHQrTjTnFrO5cRAnU3K+s2cAOH/GLSrjZTvAEFux36SO5RzQODqbdHgYKFcqETk5cxzHFQTJn8/7EvThDjVK/YmDFe6DA34XT3uoMHICxRT5v1sqQ2LbNrMWRcSZNexu/+zbOSp2pg66CL0SkWCKZH7DdooiXjF9wRwyuHieGWSBBwvTRmRESkZAI6nbNV4e0fX6rN7optzgJnfkRslIS1pKXPsw4=',
      'sig':
          'b72d145bf2745f4690f7480f019e2b0cbfb1509046a19408645519b8731183a75ec5c432c78505d31fd348fc966ca5504e0ea03c1d0b1adbeda2f7076d54945f',
    },
  ];

  static List<String> get dTags =>
      rawEvents.map((e) => (e['tags']! as List).first[1] as String).toList();
}
