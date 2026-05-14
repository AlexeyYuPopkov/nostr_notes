import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:di_storage/di_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr/model/tag/nostr_event_tags.dart';
import 'package:nostr/model/tag/tag.dart';
import 'package:nostr/model/user_keys.dart';
import 'package:nostr/nostr_client/channel_factory.dart';
import 'package:nostr/nostr_client/nostr_client.dart';
import 'package:nostr/nostr_client/nostr_event_creator.dart';
import 'package:nostr_notes/auth/data/notes_repository_impl.dart';
import 'package:nostr_notes/auth/domain/usecase/create_note_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/delete_note_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/note_crypto_use_case.dart';
import 'package:common/domain/error/error_messages_provider.dart';
import 'package:nostr_notes/common/domain/model/session/session.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';
import 'package:nostr_notes/core/event_kind.dart';
import 'package:common/services/event_store/database/app_database.dart';
import 'package:nostr_notes/services/crypto_service/crypto_service.dart';
import 'package:common/services/event_store/database/daos/outbox_dao_interface.dart';
import 'package:common/services/event_store/raw_event_store.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nostr_notes/core/tools/now.dart';
import 'package:nostr_notes/services/outbox_publisher.dart';
import 'package:uuid/uuid.dart';

import '../../../integration_test/di/in_memory_db_module.dart';
import '../../tools/mock_error_messages_provider.dart';
import '../../tools/mock_wschannel.dart';
import '../../tools/mocks/mock_relays_list_repo.dart';
import '../../tools/some_moked_data.dart';

import 'dart:async';
import 'dart:typed_data';

class _MockChannelFactory extends Mock implements ChannelFactory {}

class _MockUuid extends Mock implements Uuid {}

class _MockCryptoRepo implements CryptoService {
  @override
  Future<String> decryptNip44({
    required String payload,
    required Uint8List conversationKey,
  }) async {
    return 'message';
  }

  @override
  Future<Uint8List> deriveKeysAsync({
    required String senderPrivateKey,
    required String recipientPublicKey,
    Future<Uint8List> Function(Uint8List)? extraDerivation,
  }) async {
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

  @override
  Future<Uint8List> spec256k1Async({
    required Uint8List senderPrivateKey,
    required Uint8List recipientPublicKey,
  }) {
    return Future(
      () => spec256k1(
        senderPrivateKey: senderPrivateKey,
        recipientPublicKey: recipientPublicKey,
      ),
    );
  }

  @override
  Future<void> dispose() => Future.value();
}

class _MockExtraDerivation implements ExtraDerivation {
  @override
  Future<Uint8List> Function(Uint8List)? execute(String? password) {
    return null;
  }
}

class _MockNow implements Now {
  @override
  DateTime now() {
    return DateTime(2025, 06, 17, 13, 50);
  }
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

void main() {
  group('DeleteNoteUsecase', () {
    late NostrClient client;
    late _MockChannelFactory channelFactory;
    late MockWSChannel channel;

    late CreateNoteUsecase createNoteUsecase;
    late DeleteNoteUsecase sut;
    late OutboxDaoInterface outboxDao;
    late RawEventStore eventStore;
    late OutboxPublisher outboxPublisher;
    final mockNow = _MockNow();
    final mockUuid = _MockUuid();

    setUp(() {
      final di = DiStorage.shared;
      di.bind<ErrorMessagesProvider>(
        () => const MockErrorMessagesProvider(),
        module: null,
        lifeTime: const LifeTime.single(),
      );

      const InMemoryDbModule().bind(di);

      channelFactory = _MockChannelFactory();
      channel = MockWSChannel(url: MockRelaysListRepo.relayUrl1);
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

      outboxDao = di.resolve<OutboxDaoInterface>();
      eventStore = di.resolve<RawEventStore>();

      outboxPublisher = OutboxPublisher(
        outboxDao: outboxDao,
        rawEventStore: eventStore,
        relaysListRepo: MockRelaysListRepo.withRelays({
          MockRelaysListRepo.relayUrl1,
        }),
        channelFactory: channelFactory,
        connectivity: _MockConnectivity(),
      );

      final notesRepo = NotesRepositoryImpl(
        client: client,
        outboxDao: outboxDao,
        eventStore: eventStore,
        eventCreator: const NostrEventCreator(
          randomBytes: SomeMokedData.randomBytes,
        ),
      );

      createNoteUsecase = CreateNoteUsecase(
        sessionUsecase: sessionUsecase,
        noteCryptoUseCase: NoteCryptoUseCase(
          sessionUsecase: sessionUsecase,
          cryptoService: _MockCryptoRepo(),
          extraDerivation: _MockExtraDerivation(),
        ),
        notesRepository: notesRepo,
      );

      sut = DeleteNoteUsecase(
        sessionUsecase: sessionUsecase,
        notesRepository: notesRepo,
      );
    });

    tearDown(() async {
      await outboxPublisher.dispose();
      await client.disconnectAndDispose();
      await pumpEventQueue();
      final AppDatabase db = DiStorage.shared.resolve();
      await db.close();
      DiStorage.shared.removeAll();
    });

    test('OutboxPublisher sends both events to relay on delete', () async {
      when(() => mockUuid.v1()).thenReturn('test-dtag');
      when(() => mockUuid.v4()).thenReturn('sub-id');
      when(
        () => channelFactory.create(MockRelaysListRepo.relayUrl1),
      ).thenReturn(channel);

      // Auto-respond OK for any EVENT
      channel.onAdd = (data, ch) {
        const publishReq =
            r'["EVENT",{"kind":30023,'
            '"id":"156cf254f975ca9ca35de4a93fda13e9608a84c0b3f8e6b88029662d0aeda3f6",'
            '"pubkey":"5f23c86b8dd9a3a3fd020d5f3f87293ffcba7e66b23437a164ed41f67d75f7ee",'
            '"created_at":1750157400,'
            '"tags":[["client","996e10ba"],["t","996e10ba"],'
            '["d","test-dtag"],["p","5f23c86b8dd9a3a3fd020d5f3f87293ffcba7e66b23437a164ed41f67d75f7ee"],'
            '["summary","encrypted-message"],["updated_at","1750157400"]],'
            '"content":"encrypted-message",'
            '"sig":"a2cdab3ad4e5e55414719936df57c1df8818c5e1eb676e51a2799c1797501ba1fea73f6e7e69b18df607829b3fffe43d701be8c625f79d746df4d94fe9e6a421"}]';

        const delReq =
            r'["EVENT",{"kind":30023,'
            '"id":"7a291dae91c307d3b5bb3de60ec04fe66cf63d9c5e6ec23035c469b69b253817",'
            '"pubkey":"5f23c86b8dd9a3a3fd020d5f3f87293ffcba7e66b23437a164ed41f67d75f7ee",'
            '"created_at":1750157401,'
            '"tags":[["client","996e10ba"],["t","996e10ba"],'
            '["d","test-dtag"],["p","5f23c86b8dd9a3a3fd020d5f3f87293ffcba7e66b23437a164ed41f67d75f7ee"]],'
            '"content":"",'
            '"sig":"720519ae0c4ba91a5a2127aa9a1cc03f90142a539bf8f91183c8d92316460bd93f1b952df50eea85a0da0f0d8ecb4a2759a43c0a419dd2fc71c5d6eea1be9b3f"}]';

        if (data == publishReq || data == delReq) {
          final parsed = jsonDecode(data as String);
          final eventId = parsed[1]['id'] as String;
          ch.mockStream.add('["OK","$eventId",true,""]');
        }
      };

      // 1. Init OutboxPublisher
      await outboxPublisher.init();

      // 2. Create a note first (this will also be published)
      final createdNote = await createNoteUsecase.execute(
        content: 'message to delete',
        noteToEdit: null,
        now: mockNow,
        uuid: mockUuid,
      );

      // Wait for create to be published
      await Future.delayed(const Duration(milliseconds: 500));

      // Verify note exists in store
      final notesBefore = await eventStore.queryEvents(
        RawEventQuery(
          kinds: [EventKind.note.value],
          authors: const [SomeMokedData.publicKey],
        ),
      );
      expect(notesBefore, hasLength(1));

      // 3. Delete the note
      await sut.execute(
        note: createdNote,
        now: mockNow,
        randomBytes: SomeMokedData.randomBytes,
      );

      // 4. Wait for OutboxPublisher to publish both events
      await Future.delayed(const Duration(milliseconds: 500));

      // 5. Verify events sent to relay
      final addCalls = channel.calls
          .where((e) => e.key == 'add')
          .map((e) => jsonDecode(e.value as String) as List)
          .toList();

      final sentKinds = addCalls
          .where((e) => e[0] == 'EVENT')
          .map((e) => (e[1] as Map<String, dynamic>)['kind'] as int)
          .toSet();

      expect(sentKinds, contains(EventKind.note.value));

      // 6. Verify outbox is empty (all delivered)
      final pending = await outboxDao.getPending();
      expect(pending, isEmpty);

      // Verify note exists in store
      final notesAfter = await eventStore.queryEvents(
        RawEventQuery(
          kinds: [EventKind.note.value],
          authors: const [SomeMokedData.publicKey],
        ),
      );
      expect(notesAfter, hasLength(1));
      expect(notesAfter[0].content.isEmpty, isTrue);
      expect(notesAfter[0].getFirstTag(const SummaryTag()), isNull);
    });
  });
}
