import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:di_storage/di_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_notes/auth/data/notes_repository_impl.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/auth/domain/usecase/create_note_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/note_crypto_use_case.dart';
import 'package:nostr_notes/common/domain/error/error_messages_provider.dart';
import 'package:nostr_notes/common/domain/model/session/session.dart';
import 'package:nostr_notes/common/domain/model/session/user_keys.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';
import 'package:nostr_notes/services/event_store/database/app_database.dart';
import 'package:nostr_notes/services/crypto_service/crypto_service.dart';
import 'package:nostr_notes/services/event_store/database/daos/outbox_dao_interface.dart';
import 'package:nostr_notes/services/nostr_client/channel_factory.dart';
import 'package:nostr_notes/services/nostr_client/nostr_client.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nostr_notes/core/tools/now.dart';
import 'package:nostr_notes/services/nostr_client/outbox_publisher.dart';
import 'package:uuid/uuid.dart';

import '../../tools/di/in_memory_db_module.dart';
import '../../tools/mock_error_messages_provider.dart';
import '../../tools/mock_wschannel.dart';
import '../../tools/mocks/mock_relays_list_repo.dart';
import '../../tools/some_moked_data.dart';

class MockChannelFactory extends Mock implements ChannelFactory {}

class MockUuid extends Mock implements Uuid {}

class MockCryptoRepo implements CryptoService {
  @override
  Future<String> decryptNip44({
    required String payload,
    required Uint8List conversationKey,
  }) async {
    return 'message';
  }

  @override
  Uint8List deriveKeys({
    required String senderPrivateKey,
    required String recipientPublicKey,
    Uint8List Function(Uint8List p1)? extraDerivation,
  }) {
    return Uint8List.fromList(List<int>.generate(32, (i) => i));
  }

  @override
  Future<String> encryptNip44({
    required String plaintext,
    required Uint8List conversationKey,
    Uint8List? customNonce,
  }) async {
    return 'encrypted-message';
  }

  @override
  FutureOr<void> init() {}

  @override
  Uint8List spec256k1({
    required Uint8List senderPrivateKey,
    required Uint8List recipientPublicKey,
  }) => throw UnimplementedError();
}

class MockExtraDerivation implements ExtraDerivation {
  @override
  Uint8List Function(Uint8List)? execute(String? password) {
    return null;
  }
}

class MockNow implements Now {
  @override
  DateTime now() {
    return DateTime(2025, 06, 17, 13, 50);
  }
}

void main() {
  group('CreateNoteUsecase', () {
    late NostrClient client;
    late MockChannelFactory channelFactory;
    late MockWSChannel channel1;
    late MockWSChannel channel2;

    late CreateNoteUsecase sut1;
    late OutboxDaoInterface sut2;
    late OutboxPublisher sut3;
    final mockNow = MockNow();
    final mockUuid = MockUuid();
    final mockCryptoService = MockCryptoRepo();

    setUp(() {
      final di = DiStorage.shared;
      di.bind<ErrorMessagesProvider>(
        () => const MockErrorMessagesProvider(),
        module: null,
        lifeTime: const LifeTime.single(),
      );

      const InMemoryDbModule().bind(di);

      channelFactory = MockChannelFactory();
      channel1 = MockWSChannel(url: MockRelaysListRepo.relayUrl1);
      channel2 = MockWSChannel(url: MockRelaysListRepo.relayUrl2);
      client = NostrClient(channelFactory: channelFactory, uuid: mockUuid);

      final sessionUsecase = SessionUsecase()
        ..setSession(
          const Unlocked(
            keys: UserKeys(
              publicKey: SomeMokedData.publicKey,
              privateKey: SomeMokedData.privateKey,
            ),
            pin: '1234',
          ),
        );

      sut2 = di.resolve<OutboxDaoInterface>();

      sut3 = OutboxPublisher(
        outboxDao: sut2,
        rawEventStore: di.resolve(),
        relaysListRepo: MockRelaysListRepo.withStubRelays(),
        channelFactory: channelFactory,
        connectivity: _MockConnectivity(),
      );

      sut1 = CreateNoteUsecase(
        sessionUsecase: sessionUsecase,
        noteCryptoUseCase: NoteCryptoUseCase(
          sessionUsecase: sessionUsecase,
          cryptoService: mockCryptoService,
          extraDerivation: MockExtraDerivation(),
        ),
        notesRepository: NotesRepositoryImpl(
          client: client,
          outboxDao: sut2,
          eventStore: di.resolve(),
        ),
      );
    });

    tearDown(() async {
      await sut3.dispose();
      await client.disconnectAndDispose();
      await pumpEventQueue();
      final AppDatabase db = DiStorage.shared.resolve();
      await db.close();
      DiStorage.shared.removeAll();
    });

    test('successful note creation saves to store and outbox', () async {
      when(() => mockUuid.v1()).thenReturn('uuid-v1');

      final note = await sut1.execute(
        content: 'message',
        dTag: null,
        now: mockNow,
        uuid: mockUuid,
        randomBytes: SomeMokedData.randomBytes,
      );

      expect(note, isA<Note>());
      expect(note.content, 'message');
      expect(note.dTag, 'uuid-v1');

      // Verify event was inserted into outbox
      final pending = await sut2.getPending();
      expect(pending, hasLength(1));
      expect(pending.first.eventId, isNotEmpty);
    });

    test(
      'OutboxPublisher picks up event and publishes to both relays',
      () async {
        const eventId =
            '9d1c1d765e572b5914ed838cba42bb22b9fb50f5ac0532c494caf75bc7363143';
        when(() => mockUuid.v1()).thenReturn('uuid-v1');
        when(() => mockUuid.v4()).thenReturn('sub-id');
        when(
          () => channelFactory.create(MockRelaysListRepo.relayUrl1),
        ).thenReturn(channel1);
        when(
          () => channelFactory.create(MockRelaysListRepo.relayUrl2),
        ).thenReturn(channel2);

        const response = '''["OK","$eventId",true,""]''';

        channel1.onAdd = (data, channel) {
          channel.mockStream.add(response);
        };

        channel2.onAdd = (data, channel) {
          channel.mockStream.add(response);
        };

        // 1. Init OutboxPublisher so it watches pending events
        await sut3.init();

        // 2. Create note -> saves to store + outbox
        final note = await sut1.execute(
          content: 'message',
          dTag: null,
          now: mockNow,
          uuid: mockUuid,
          randomBytes: SomeMokedData.randomBytes,
        );

        expect(note, isA<Note>());

        // 3. Wait for OutboxPublisher to pick up and publish
        await Future.delayed(const Duration(milliseconds: 200));

        // 4. Verify channels received the event
        expect(channel1.verifyAddCalled(), 1);
        expect(channel2.verifyAddCalled(), 1);

        const sentEvent = r'''
          ["EVENT",{
          "kind":30023,
          "id":"9d1c1d765e572b5914ed838cba42bb22b9fb50f5ac0532c494caf75bc7363143",
          "pubkey":"5f23c86b8dd9a3a3fd020d5f3f87293ffcba7e66b23437a164ed41f67d75f7ee",
          "created_at":1750157400,
          "tags":[["client","996e10ba"],["t","996e10ba"],["d","uuid-v1"],["p","5f23c86b8dd9a3a3fd020d5f3f87293ffcba7e66b23437a164ed41f67d75f7ee"],["summary","encrypted-message"]],
          "content":"encrypted-message",
          "sig":"ceb65b126c335f6659769493ae8c309f9061c9cd11dd34d3e0fa606f2e40d9b5bc26f041a26b8ecf124aaa5d0d3438a21761ebc956a10aa576ea67c916696950"}]
        ''';

        final eventJson = jsonDecode(sentEvent);

        final addCall1 = channel1.calls.firstWhere((e) => e.key == 'add');
        final addCall2 = channel2.calls.firstWhere((e) => e.key == 'add');
        expect(jsonDecode(addCall1.value), eventJson);
        expect(jsonDecode(addCall2.value), eventJson);

        // 5. Verify outbox marked as sent
        final pending = await sut2.getPending();
        expect(pending, isEmpty);
      },
    );

    test('OutboxPublisher publishes with partial relay response', () async {
      const eventId =
          '9d1c1d765e572b5914ed838cba42bb22b9fb50f5ac0532c494caf75bc7363143';
      when(() => mockUuid.v1()).thenReturn('uuid-v1');
      when(() => mockUuid.v4()).thenReturn('sub-id');
      when(
        () => channelFactory.create(MockRelaysListRepo.relayUrl1),
      ).thenReturn(channel1);
      when(
        () => channelFactory.create(MockRelaysListRepo.relayUrl2),
      ).thenReturn(channel2);

      const response = '''["OK","$eventId",true,""]''';

      // Only relay1 responds
      channel1.onAdd = (data, channel) {
        channel.mockStream.add(response);
      };

      await sut3.init();

      final note = await sut1.execute(
        content: 'message',
        dTag: null,
        now: mockNow,
        uuid: mockUuid,
        randomBytes: SomeMokedData.randomBytes,
      );

      expect(note, isA<Note>());

      // Wait for publish (includes 2s timeout for relay2)
      await Future.delayed(const Duration(seconds: 3));

      expect(channel1.verifyAddCalled(), 1);
      expect(channel2.verifyAddCalled(), 1);

      const sentEvent = r'''
          ["EVENT",{
          "kind":30023,
          "id":"9d1c1d765e572b5914ed838cba42bb22b9fb50f5ac0532c494caf75bc7363143",
          "pubkey":"5f23c86b8dd9a3a3fd020d5f3f87293ffcba7e66b23437a164ed41f67d75f7ee",
          "created_at":1750157400,
          "tags":[["client","996e10ba"],["t","996e10ba"],["d","uuid-v1"],["p","5f23c86b8dd9a3a3fd020d5f3f87293ffcba7e66b23437a164ed41f67d75f7ee"],["summary","encrypted-message"]],
          "content":"encrypted-message",
          "sig":"ceb65b126c335f6659769493ae8c309f9061c9cd11dd34d3e0fa606f2e40d9b5bc26f041a26b8ecf124aaa5d0d3438a21761ebc956a10aa576ea67c916696950"}]
        ''';

      final eventJson = jsonDecode(sentEvent);

      final addCall1 = channel1.calls.firstWhere((e) => e.key == 'add');
      final addCall2 = channel2.calls.firstWhere((e) => e.key == 'add');
      expect(jsonDecode(addCall1.value), eventJson);
      expect(jsonDecode(addCall2.value), eventJson);
    });
  });
}

class _MockConnectivity implements Connectivity {
  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => [
    ConnectivityResult.wifi,
  ];

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      const Stream.empty();
}
