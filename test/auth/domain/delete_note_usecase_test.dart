import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:di_storage/di_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_notes/auth/data/notes_repository_impl.dart';
import 'package:nostr_notes/auth/domain/usecase/create_note_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/delete_note_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/note_crypto_use_case.dart';
import 'package:nostr_notes/common/domain/error/error_messages_provider.dart';
import 'package:nostr_notes/common/domain/model/session/session.dart';
import 'package:nostr_notes/common/domain/model/session/user_keys.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';
import 'package:nostr_notes/core/event_kind.dart';
import 'package:nostr_notes/services/event_store/database/app_database.dart';
import 'package:nostr_notes/services/crypto_service/crypto_service.dart';
import 'package:nostr_notes/services/event_store/database/daos/outbox_dao_interface.dart';
import 'package:nostr_notes/services/event_store/raw_event_store.dart';
import 'package:nostr_notes/services/model/tag/nostr_event_tags.dart';
import 'package:nostr_notes/services/model/tag/tag.dart';
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

class _MockExtraDerivation implements ExtraDerivation {
  @override
  Uint8List Function(Uint8List)? execute(String? password) {
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
        final parsed = jsonDecode(data as String);
        if (parsed[0] == 'EVENT') {
          final eventId = parsed[1]['id'] as String;
          ch.mockStream.add('["OK","$eventId",true,""]');
        }
      };

      // 1. Init OutboxPublisher
      await outboxPublisher.init();

      // 2. Create a note first (this will also be published)
      final createdNote = await createNoteUsecase.execute(
        content: 'message to delete',
        dTag: null,
        now: mockNow,
        uuid: mockUuid,
        randomBytes: SomeMokedData.randomBytes,
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

      expect(sentKinds, contains(EventKind.delete.value));

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
      expect(notesAfter, hasLength(0));

      // Verify note exists in store
      final deletionEvent = await eventStore.queryEvents(
        RawEventQuery(
          kinds: [EventKind.delete.value],
          authors: const [SomeMokedData.publicKey],
        ),
      );
      expect(deletionEvent, hasLength(1));
      expect(deletionEvent[0].kind, 5);
      expect(
        deletionEvent[0].pubkey,
        '5f23c86b8dd9a3a3fd020d5f3f87293ffcba7e66b23437a164ed41f67d75f7ee',
      );
      expect(
        deletionEvent[0].getFirstTag(Tag.a),
        '30023:5f23c86b8dd9a3a3fd020d5f3f87293ffcba7e66b23437a164ed41f67d75f7ee:test-dtag',
      );
    });
  });
}
