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
/// the `content` is real NIP-44 ciphertext encrypted under PIN [_pin] — so
/// this test's session genuinely decrypts them.
final class _Helper {
  static const rawEvents = [
    {
      'kind': 31023,
      'id': 'a478aee5eccd9876faa58028fcb872df1152c6c7458ed0cc71dd3b0707378ce5',
      'pubkey':
          'd02386c8255ae21c4ff24f1df5d7f630943e333f614eda317e73deedb7f2b7c3',
      'created_at': 1786275327,
      'tags': [
        ['d', 'b7af2c7c-88a3-4fee-97de-15a1de886fc6'],
      ],
      'content':
          'AihMXR9z+cQ4RRdidBMdkjP5Ph/TsF/P85LoHmGwB0EJD/SnHWOinJmICW88NM4JFgx3ewCgfgKwhXw5JNHsQmMsvMS3zZVPipZGwb2WGiCd1EsSyjQXbVwvU13N9PddcmJtsKZOwTJZNRRzkCVBRFsaclc52gjOyrFhw5qv8Ddw0V+Yvl1Yxl4z8yj/tEWCe9EY1JpuC0Ek98ThBmBCWxxMGJHvtj0N/9SNe8hEkQwm+unFFegbmQ0kSRi5TOcVHKMV56YP7irwl9fWhV+tk5Dgx6rfz6piaceVtf4gXdqQ+e8=',
      'sig':
          '39295723ff71e828c4232240cff14debb44c95d8bd68cbd740e56a621bc2e6f192f566105e333e98d318965cf1d1597c957c232fdad5d28be948af0114464bb2',
    },
    {
      'kind': 31023,
      'id': '02809810a1cc21a752488d950e6ef70ced79c884f27741f18d8ae20ad49c0917',
      'pubkey':
          'd02386c8255ae21c4ff24f1df5d7f630943e333f614eda317e73deedb7f2b7c3',
      'created_at': 1786275287,
      'tags': [
        ['d', '30d5086c-6e55-4227-80d8-cd923f474d49'],
      ],
      'content':
          'Ajt+28mTjKkw+yJk8tn/GYTy7euBOC7vedW4lpGQ/ytStH4Eie/xDbPo5IMVIhju+e9c1ytbKG3JZC1arF9ovKSarVbb3PnJjiABW2kB9NpkS7fZD9ocpzWGUlgI0e/SDzvtr9T4I6mOwsMgr07LOY0JJxAWl6MWsGpsPPTJN+/NnN3XVCCc9g31Pib7EcLwgzGzEnEFFcs3TQR/Yok50kB4XULqMc+CIz48k2RyT2Tjf+oDeKU2ozy3tjczDTFl0Nwvr4c4wWDwj9f7lq57myyj9Px2eegSqsWXrjJIjiCjSzM=',
      'sig':
          'f2d9b0a5ccdb58f495540e3536a9ce351d2f3adeecd1f6379b4ae8bed886bb12cebae9df40148ef813ffc2197c54cadb43dc9c6e6afc0b29cbce7887ba587c1e',
    },
    {
      'kind': 31023,
      'id': 'af01c3383432b0e3c9291c255220a64587cdd46b06814408d666ea2bb32bca85',
      'pubkey':
          'd02386c8255ae21c4ff24f1df5d7f630943e333f614eda317e73deedb7f2b7c3',
      'created_at': 1786275237,
      'tags': [
        ['d', 'f5ea33c2-4184-4376-8994-ef5a3ff3b531'],
      ],
      'content':
          'Alqm7Yl8QXUaBQJNv8twK/VZGbE3BsqhkJfgzjPXQ4cDd73aEZc7itqNDgb2MLQH/6KMNgkqhSVro7mDCZ3HbOgjjRQ1A9hihDtUxlHByM9xqVcMGRpXWP8vpcUUFvvvC/fTGAUydZIiGzaGhb8+6DRWGjAtQkzKfkF/fG8kjJb+k0BSF3S3FN9pgM6meclokGPS1OKxoyldROYR3eJOz1osSU05NVzM6JQYGYSbslw6TdouQOcaKS4u1QnmBj3/yMBRvKXzVu1oAbbUIFWFAc+23TWVo55g2iODGhxr9cQNY44=',
      'sig':
          'b7ab6b3db5f14a3cb9bdd18e19413c2ebb880d7c2ee216b2e73d3fb2cf1e5d0e2398cee810ac140295ac4c0e51142f2b50f1faa29ca24b15f9de090b301162bd',
    },
  ];

  static List<String> get dTags =>
      rawEvents.map((e) => (e['tags']! as List).first[1] as String).toList();
}
