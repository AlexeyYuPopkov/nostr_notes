import 'dart:convert';

import 'package:common/data/zap/fetch_user_zapper_service.dart';
import 'package:common/data/zap/perform_lighting_invoice_service.dart';
import 'package:common/data/zap/zapper.dart';
import 'package:common/domain/error/app_error.dart';
import 'package:common/domain/repo/relays_list_repo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nostr/model/nostr_event.dart';
import 'package:nostr/model/user_keys.dart';
import 'package:nostr/nostr_client/nostr_event_creator.dart';
import 'package:nostr_notes/app/app_config.dart';
import 'package:nostr_notes/auth/data/lightning_donation_repo_impl.dart';
import 'package:nostr_notes/common/domain/model/session/session.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';
import 'package:nostr_notes/core/tools/now.dart';

import '../../tools/some_moked_data.dart';

final class MockFetchUserZapperService extends Mock
    implements FetchUserZapperService {}

class _MockNow implements Now {
  @override
  DateTime now() {
    return DateTime.fromMillisecondsSinceEpoch(1779888816 * 1000);
  }
}

class _SpyRelaysListRepo implements RelaysListRepo {
  int getRelaysListCallCount = 0;

  @override
  Set<String> getRelaysList() {
    getRelaysListCallCount++;
    return {'wss://relay.example.com'};
  }

  @override
  Future<void> saveRelaysList(Set<String> relays) async {}

  @override
  Set<String> getSuggestedRelays() => const {};

  @override
  Stream<Set<String>> get relaysListStream => const Stream.empty();

  @override
  Future<void> clear() async {}

  @override
  Future<void> dispose() async {}
}

void main() {
  const expectedInvoice =
      'lnbc10u1p4pdu2qpp5ge4rnn8jfyl0nhkdppn736695lhq8nntf3fj2aws2q06vn0s0v8qhp5h35070hw94tuenc4z3945s04fj5uzdwja0qqfl9kzdaea97apxeqcqzzsxqyz5vqsp5eld6uq89kt3g9yzkkrzglvh5g8spqna8l8k540unlujayyhyxdeq9qxpqysgq4gxtqtd0zy25ndz6pp4q3g03lz4wy388paxzyml3xwkqxjlealtjygkgt93w7k4s6zu3gvs3mc0gvf3nfd7wfaqgm0nc344xenhf8pqpy395ss';

  const expectedZapper = UserDataZapper(
    callback:
        'https://livingroomofsatoshi.com/api/v1/lnurl/payreq/dfa813d7-0582-42b9-98b8-baf0abb6a0ed',
    maxSendable: 100000000000,
    minSendable: 1000,
    metadata:
        '[["text/plain","Pay to Wallet of Satoshi user: visualgemini28"],["text/identifier","visualgemini28@walletofsatoshi.com"]]',
    tag: 'payRequest',
    allowsNostr: true,
    nostrPubkey:
        'be1d89794bf92de5dd64c1e60f6a2c70c140abac9932418fee30c5c637fe9479',
    originalLnurl:
        'lnurl1dp68gurn8ghj7ampd3kx2ar0veekzar0wd5xjtnrdakj7tnhv4kxctttdehhwm30d3h82unvwqhhv6tnw4skcem9d45ku6fj8qzjdgp8',
  );

  setUpAll(() {
    registerFallbackValue(
      const NostrEvent(
        kind: 0,
        id: '',
        pubkey: '',
        createdAt: 0,
        tags: [],
        content: '',
        sig: '',
      ),
    );
  });

  group('LightningDonationRepoImpl', () {
    late SessionUsecase sessionUsecase;
    late _SpyRelaysListRepo relaysListRepo;
    late MockFetchUserZapperService fetchUserZapperService;
    late _MockNow mockNow;
    late LightningDonationRepoImpl sut;

    setUp(() {
      sessionUsecase = SessionUsecase();
      relaysListRepo = _SpyRelaysListRepo();
      fetchUserZapperService = MockFetchUserZapperService();
      mockNow = _MockNow();
      sut = LightningDonationRepoImpl(
        sessionUsecase: sessionUsecase,
        relaysListRepo: relaysListRepo,
        performLightingInvoiceService: PerformLightingInvoiceService(
          fetchUserZapperService: fetchUserZapperService,
          // FetchUserZapperService(), // fetchUserZapperService,
          zapEventCreator: ZapEventCreator(
            now: mockNow,
            eventCreator: const NostrEventCreator(
              randomBytes: SomeMokedData.randomBytes,
            ),
          ),
        ),
      );
    });

    tearDown(() async {
      await sessionUsecase.dispose();
    });

    test('throws NotAuthenticatedError when session has no keys', () async {
      await expectLater(
        () => sut.getInvoice(sats: 21),
        throwsA(isA<NotAuthenticatedError>()),
      );

      expect(relaysListRepo.getRelaysListCallCount, 0);
    });

    test('perform lightning invoice', () async {
      await sessionUsecase.setSession(
        const Unlocked(
          keys: UserKeys(
            publicKey: SomeMokedData.publicKey,
            privateKey: SomeMokedData.privateKey,
          ),
          pin: '1234',
        ),
      );

      when(
        () => fetchUserZapperService.fetchUserZapper(
          AppConfig.kDevLightningAddress,
        ),
      ).thenAnswer((_) async => expectedZapper);

      const invoiceEventStr =
          r'{"kind":9734,'
          '"id":"7602e2cf416ac396c45559d151d9c54e4df5b47563fe9966fec982eebad476a3",'
          '"pubkey":"5f23c86b8dd9a3a3fd020d5f3f87293ffcba7e66b23437a164ed41f67d75f7ee",'
          '"created_at":1779888816,'
          '"tags":[["relays","wss://relay.example.com"],["amount","1000000"],'
          '["lnurl","lnurl1dp68gurn8ghj7ampd3kx2ar0veekzar0wd5xjtnrdakj7tnhv4kxctttdehhwm30d3h82unvwqhhv6tnw4skcem9d45ku6fj8qzjdgp8"],'
          '["p","cf2e0ca7070a28e7c24041160689f37bedd654a86a86bb172881b00621f250e3"]],'
          '"content":"",'
          '"sig":"2ab8d7c29e6fee7ec4d73ea80e2afabf090c196225f7ac2cdad08d97fd9f9fff47710a4178e431b3051e6698100c557899c2e98ddb0fe92e4462a5c8c3b270eb"}';

      final invoiceEvent = NostrEvent.fromJson(jsonDecode(invoiceEventStr));

      when(
        () => fetchUserZapperService.getInvoice(
          zapper: expectedZapper,
          sats: 1000,
          event: invoiceEvent,
        ),
      ).thenAnswer((_) async => expectedInvoice);

      final invoice = await sut.getInvoice(sats: 1000);

      expect(invoice, expectedInvoice);
      expect(relaysListRepo.getRelaysListCallCount, 1);

      // verify(
      //   () => fetchUserZapperService.fetchUserZapper(
      //     AppConfig.kDevLightningAddress,
      //   ),
      // ).called(1);

      // final capturedInvocation = verify(
      //   () => fetchUserZapperService.getInvoice(
      //     zapper: expectedZapper,
      //     sats: 1000,
      //     event: NostrEvent.fromJson(jsonDecode(invoiceEvent)),
      //   ),
      // ).captured;
      // expect(capturedInvocation.length, 1);
      // final capturedEvent = capturedInvocation.single as NostrEvent;

      // expect(capturedEvent.id, expectedEvent.id);
    });
  });
}
