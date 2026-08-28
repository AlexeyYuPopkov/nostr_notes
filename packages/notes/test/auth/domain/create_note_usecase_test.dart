import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:common/domain/error/error_messages_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:di_storage/di_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr/model/user_keys.dart';
import 'package:nostr/nostr_client/channel_factory.dart';
import 'package:nostr/nostr_client/nostr_client.dart';
import 'package:nostr/nostr_client/nostr_event_creator.dart';
import 'package:nostr_notes/auth/data/notes_repository_impl.dart';
import 'package:nostr_notes/auth/domain/model/label.dart';
import 'package:common/services/event_store/raw_event_store.dart';
import 'package:nostr_notes/auth/data/mappers/note_mapper.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/auth/domain/usecase/create_note_usecase.dart';
import 'package:nostr_notes/auth/domain/model/pin_kdf.dart';
import 'package:nostr_notes/auth/domain/usecase/note_crypto_use_case.dart';
import 'package:nostr_notes/common/domain/model/session/session.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';
import 'package:common/services/event_store/database/app_database.dart';
import 'package:nostr_notes/services/crypto_service/crypto_service.dart';
import 'package:common/services/event_store/database/daos/outbox_dao_interface.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nostr_notes/core/tools/now.dart';
import 'package:nostr_notes/services/outbox_publisher.dart';
import 'package:uuid/uuid.dart';

import '../../../integration_test/di/in_memory_db_module.dart';
import '../../tools/mock_error_messages_provider.dart';
import '../../tools/mock_wschannel.dart';
import '../../tools/mocks/mock_relays_list_repo.dart';
import '../../tools/some_moked_data.dart';

class MockChannelFactory extends Mock implements ChannelFactory {}

class MockUuid extends Mock implements Uuid {}

class MockExtraDerivation implements ExtraDerivation {
  @override
  Future<Uint8List> Function(Uint8List)? execute(
    String? password, {
    PinKdf kdf = PinKdf.current,
  }) {
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

    final sut4 = CryptoService.create(
      Uint8List.fromList(SomeMokedData.randomBytes),
    );
    final mockNow = MockNow();
    final mockUuid = MockUuid();

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
          cryptoService: sut4,
          extraDerivation: MockExtraDerivation(),
        ),
        notesRepository: NotesRepositoryImpl(
          client: client,
          outboxDao: sut2,
          eventStore: di.resolve(),
          eventCreator: const NostrEventCreator(
            randomBytes: SomeMokedData.randomBytes,
          ),
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
        noteToEdit: null,
        now: mockNow,
        uuid: mockUuid,
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
      'a note saved with a PIN can be read back and decrypted',
      () async {
        when(() => mockUuid.v1()).thenReturn('uuid-v1');

        final di = DiStorage.shared;
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
        // The real ExtraDerivation, not the mock the other tests use: the KDF
        // version has to survive the trip through the event's tags, and a null
        // derivation never exercises that.
        final crypto = NoteCryptoUseCase(
          sessionUsecase: sessionUsecase,
          cryptoService: sut4,
          extraDerivation: ExtraDerivation(
            cryptoService: sut4,
            sessionUsecase: sessionUsecase,
          ),
        );
        final usecase = CreateNoteUsecase(
          sessionUsecase: sessionUsecase,
          noteCryptoUseCase: crypto,
          notesRepository: NotesRepositoryImpl(
            client: client,
            outboxDao: sut2,
            eventStore: di.resolve(),
            eventCreator: const NostrEventCreator(
              randomBytes: SomeMokedData.randomBytes,
            ),
          ),
        );

        await usecase.execute(
          content: 'message',
          noteToEdit: null,
          now: mockNow,
          uuid: mockUuid,
        );

        final RawEventStore store = di.resolve();
        final stored = await store.queryEvents(
          const RawEventQuery(kinds: [30023]),
        );
        final saved = NoteMapper.fromNostrEvent(stored.single)!;

        expect(
          saved.kdf,
          PinKdf.current,
          reason:
              'the KDF version must be recorded on the event itself — without '
              'it the note reads back as legacy and decrypts to garbage',
        );
        expect((await crypto.decryptNote(saved)).content, 'message');
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );

    test('OutboxPublisher picks up event and publishes to both relays', () async {
      const eventId =
          '60f8bdecef9ce60bb0ff228a8b1e346d38f3bea771516ba91f36ccbb56c71998';
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
      final noteToEdit = Note(
        eventId: '',
        dTag: '',
        content: '',
        summary: '',
        createdAt: DateTime(2025),
        updatedAt: DateTime(2025),
        labels: [Label.from('work'), Label.from('journal')],
      );
      final note = await sut1.execute(
        content: 'message',
        noteToEdit: noteToEdit,
        now: mockNow,
        uuid: mockUuid,
      );

      expect(note, isA<Note>());

      // 3. Wait for OutboxPublisher to pick up and publish
      await Future.delayed(const Duration(milliseconds: 200));

      // 4. Verify channels received the event
      expect(channel1.verifyAddCalled(), 1);
      expect(channel2.verifyAddCalled(), 1);

      const sentEvent =
          '["EVENT",{'
          '"kind":30023,'
          '"id":"60f8bdecef9ce60bb0ff228a8b1e346d38f3bea771516ba91f36ccbb56c71998",'
          '"pubkey":"5f23c86b8dd9a3a3fd020d5f3f87293ffcba7e66b23437a164ed41f67d75f7ee",'
          '"created_at":1750157400,'
          '"tags":[["client","996e10ba"],["t","996e10ba"],["d","uuid-v1"],'
          '["p","5f23c86b8dd9a3a3fd020d5f3f87293ffcba7e66b23437a164ed41f67d75f7ee"],'
          '["summary","AuXvY0J+AMpiCAy3NWZxZgQ9mz6UDHcitHPicTq5W8w5MgglehbzsNjlKVP2pURGJCzdQgzLK8YLoTvhDY+2SM3HQaY62I4LStarNw5IQJc7dgdfVkUof7BqVEJ8YsAUvjfC"],'
          '["pin_kdf","2"],'
          '["updated_at","1750157400"],'
          '["labels","AuXvY0J+AMpiCAy3NWZxZgQ9mz6UDHcitHPicTq5W8w5Mh0TPRLvo9SiBXGcyjE0Sk2xYFHLK8YLoTvhDY+2SM3HQXyVyN0bWhAykUrQVvd8hxVQqvF/Ti2tKbQ74GFrSasx"]],'
          '"content":"AuXvY0J+AMpiCAy3NWZxZgQ9mz6UDHcitHPicTq5W8w5MgglehbzsNjlKVP2pURGJCzdQgzLK8YLoTvhDY+2SM3HQaY62I4LStarNw5IQJc7dgdfVkUof7BqVEJ8YsAUvjfC",'
          '"sig":"af39f6e3a26411cf0bdb907f692c433f621b152ee40bc4a1d7072568f501b20c8ce58e90eb06f1a88d0d00a4e766d2fe06002ade4df7eee050bd3ab125f0e777"}]';

      final eventJson = jsonDecode(sentEvent);

      final addCall1 = channel1.calls.firstWhere((e) => e.key == 'add');
      final addCall2 = channel2.calls.firstWhere((e) => e.key == 'add');
      expect(jsonDecode(addCall1.value), eventJson);
      expect(jsonDecode(addCall2.value), eventJson);

      // 5. Verify outbox marked as sent
      final pending = await sut2.getPending();
      expect(pending, isEmpty);
    });

    test('OutboxPublisher publishes with partial relay response', () async {
      const eventId =
          '60f8bdecef9ce60bb0ff228a8b1e346d38f3bea771516ba91f36ccbb56c71998';
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

      final noteToEdit = Note(
        eventId: '',
        dTag: '',
        content: '',
        summary: '',
        createdAt: DateTime(2025),
        updatedAt: DateTime(2025),
        labels: [Label.from('work'), Label.from('journal')],
      );
      final note = await sut1.execute(
        content: 'message',
        noteToEdit: noteToEdit,
        now: mockNow,
        uuid: mockUuid,
      );

      expect(note, isA<Note>());

      // Wait for publish (includes 2s timeout for relay2)
      await Future.delayed(const Duration(seconds: 3));

      expect(channel1.verifyAddCalled(), 1);
      expect(channel2.verifyAddCalled(), 1);

      const sentEvent =
          '["EVENT",{'
          '"kind":30023,'
          '"id":"60f8bdecef9ce60bb0ff228a8b1e346d38f3bea771516ba91f36ccbb56c71998",'
          '"pubkey":"5f23c86b8dd9a3a3fd020d5f3f87293ffcba7e66b23437a164ed41f67d75f7ee",'
          '"created_at":1750157400,'
          '"tags":[["client","996e10ba"],["t","996e10ba"],["d","uuid-v1"],'
          '["p","5f23c86b8dd9a3a3fd020d5f3f87293ffcba7e66b23437a164ed41f67d75f7ee"],'
          '["summary","AuXvY0J+AMpiCAy3NWZxZgQ9mz6UDHcitHPicTq5W8w5MgglehbzsNjlKVP2pURGJCzdQgzLK8YLoTvhDY+2SM3HQaY62I4LStarNw5IQJc7dgdfVkUof7BqVEJ8YsAUvjfC"],'
          '["pin_kdf","2"],'
          '["updated_at","1750157400"],'
          '["labels","AuXvY0J+AMpiCAy3NWZxZgQ9mz6UDHcitHPicTq5W8w5Mh0TPRLvo9SiBXGcyjE0Sk2xYFHLK8YLoTvhDY+2SM3HQXyVyN0bWhAykUrQVvd8hxVQqvF/Ti2tKbQ74GFrSasx"]],'
          '"content":"AuXvY0J+AMpiCAy3NWZxZgQ9mz6UDHcitHPicTq5W8w5MgglehbzsNjlKVP2pURGJCzdQgzLK8YLoTvhDY+2SM3HQaY62I4LStarNw5IQJc7dgdfVkUof7BqVEJ8YsAUvjfC",'
          '"sig":"af39f6e3a26411cf0bdb907f692c433f621b152ee40bc4a1d7072568f501b20c8ce58e90eb06f1a88d0d00a4e766d2fe06002ade4df7eee050bd3ab125f0e777"}]';

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
