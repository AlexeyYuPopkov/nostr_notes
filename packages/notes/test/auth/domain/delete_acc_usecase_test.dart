import 'dart:convert';
import 'package:di_storage/di_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr/model/nostr_event.dart';
import 'package:nostr/nostr_client/channel_factory.dart';
import 'package:nostr/nostr_client/nostr_client.dart';
import 'package:nostr/nostr_client/nostr_event_creator.dart';
import 'package:nostr_notes/auth/data/notes_repository_impl.dart';
import 'package:nostr_notes/auth/domain/usecase/delete_acc_usecase.dart';
import 'package:nostr_notes/common/data/key_tool_repository_impl.dart';
import 'package:nostr_notes/common/domain/error/error_messages_provider.dart';
import 'package:nostr_notes/common/domain/model/session/session.dart';
import 'package:nostr_notes/common/domain/model/session/user_keys.dart';
import 'package:nostr_notes/common/domain/repository/secure_storage.dart';
import 'package:nostr_notes/common/domain/usecase/auth_usecase.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';
import 'package:nostr_notes/core/event_kind.dart';
import 'package:nostr_notes/services/event_store/database/app_database.dart';
import 'package:nostr_notes/services/event_store/database/daos/outbox_dao_interface.dart';
import 'package:nostr_notes/services/event_store/raw_event_store.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nostr_notes/core/tools/now.dart';
import 'package:uuid/uuid.dart';

import '../../tools/di/in_memory_db_module.dart';
import '../../tools/mock_error_messages_provider.dart';
import '../../tools/mock_wschannel.dart';
import '../../tools/mocks/mock_relays_list_repo.dart';
import '../../tools/mocks/mock_secure_storage.dart';
import '../../tools/some_moked_data.dart';

import 'dart:typed_data';

class _MockChannelFactory extends Mock implements ChannelFactory {}

class _MockUuid extends Mock implements Uuid {}

class _MockNow implements Now {
  @override
  DateTime now() {
    return DateTime(2026, 03, 20);
  }
}

void main() {
  group('DeleteNoteUsecase', () {
    late NostrClient client;
    late _MockChannelFactory channelFactory;
    late MockWSChannel channel;

    late DeleteAccUsecase sut;
    late OutboxDaoInterface outboxDao;
    late RawEventStore eventStore;
    late NotesRepositoryImpl notesRepo;
    late SecureStorage secureStorage;
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

      notesRepo = NotesRepositoryImpl(
        client: client,
        outboxDao: outboxDao,
        eventStore: eventStore,
        now: mockNow,
        eventCreator: NostrEventCreator(
          randomBytes: Uint8List.fromList(List<int>.generate(32, (i) => i)),
        ),
      );

      secureStorage = MockSecureStorage();

      final relaysListRepo = MockRelaysListRepo.withRelays({
        MockRelaysListRepo.relayUrl1,
      });

      sut = DeleteAccUsecase(
        sessionUsecase: sessionUsecase,
        notesRepository: notesRepo,
        relaysListRepo: relaysListRepo,
        authUsecase: AuthUsecase(
          secureStorage: secureStorage,
          sessionUsecase: sessionUsecase,
          keyToolRepository: const KeyToolRepositoryImpl(),
          relaysListRepo: relaysListRepo,
        ),
      );
    });

    tearDown(() async {
      await client.disconnectAndDispose();
      await pumpEventQueue();
      final AppDatabase db = DiStorage.shared.resolve();
      await db.close();
      DiStorage.shared.removeAll();
    });

    test('Acc deletion', () async {
      when(
        () => channelFactory.create(MockRelaysListRepo.relayUrl1),
      ).thenReturn(channel);

      await eventStore.upsert([_Helper.event1, _Helper.event2]);

      channel.onAdd = (data, ch) {
        const delReq =
            r'["EVENT",'
            '{"kind":5,'
            '"id":"6e48a44c95ceb083fa4ea975a903b8166ecf3ad848ca7cf8c7a5ea28ecb7641a",'
            '"pubkey":"5f23c86b8dd9a3a3fd020d5f3f87293ffcba7e66b23437a164ed41f67d75f7ee",'
            '"created_at":1773957600,'
            '"tags":['
            '["a","30023:5f23c86b8dd9a3a3fd020d5f3f87293ffcba7e66b23437a164ed41f67d75f7ee:note1-d-tag"],'
            '["a","30023:5f23c86b8dd9a3a3fd020d5f3f87293ffcba7e66b23437a164ed41f67d75f7ee:note2-d-tag"],'
            '["k","30023"]],'
            '"content":"",'
            '"sig":"451f963f9bea3b6ea0890174f5dfd81bafd83fa484f23f9f8488a3e9b0813550c7e7f4add2c4006fd84d9ece699cb7c0cfcd697c40bc61e40e874c4d21433481"}]';

        if (data is String && data == delReq) {
          final parsed = jsonDecode(data);
          final eventId = parsed[1]['id'] as String;
          ch.mockStream.add('["OK","$eventId",true,""]');
        }
      };

      final notesBefore = await eventStore.queryEvents(
        RawEventQuery(
          kinds: [EventKind.note.value],
          authors: const [SomeMokedData.publicKey],
        ),
      );
      expect(notesBefore, hasLength(2));

      secureStorage.setValue(
        key: AuthUsecase.secureStorageKey,
        value: SomeMokedData.privateKey,
      );

      expect(
        await secureStorage.getValue(key: AuthUsecase.secureStorageKey),
        SomeMokedData.privateKey,
      );

      final resultStream = sut.execute().asBroadcastStream();

      await expectLater(resultStream, emitsInOrder(DeleteAccStatus.steps));

      final notesAfter = await eventStore.queryEvents(
        RawEventQuery(
          kinds: [EventKind.note.value],
          authors: const [SomeMokedData.publicKey],
        ),
      );
      expect(notesAfter.isEmpty, isTrue);

      final deletionEventWasStored = await eventStore.queryEvents(
        RawEventQuery(
          kinds: [EventKind.delete.value],
          authors: const [SomeMokedData.publicKey],
        ),
      );

      expect(deletionEventWasStored, hasLength(1));

      // If BD contains deletion events - cannot get any note with deleted dTag

      await eventStore.upsert([_Helper.event1, _Helper.event2]);

      final getNotesResult = await notesRepo.getNotes(
        pubkey: SomeMokedData.publicKey,
      );

      expect(getNotesResult, isA<Iterable>());
      expect(getNotesResult.isEmpty, isTrue);

      final watchNotesResult = await notesRepo
          .watchNotes(pubkey: SomeMokedData.publicKey)
          .first;

      expect(watchNotesResult, isA<Iterable>());
      expect(watchNotesResult.isEmpty, isTrue);

      final privateKey = await secureStorage.getValue(
        key: SomeMokedData.publicKey,
      );

      expect(privateKey, '');
    });
  });
}

final class _Helper {
  static const note1 = r'''
          {
          "kind":30023,
          "id":"note1-id",
          "pubkey":"5f23c86b8dd9a3a3fd020d5f3f87293ffcba7e66b23437a164ed41f67d75f7ee",
          "created_at":1750157400,
          "tags":[["client","996e10ba"],["t","996e10ba"],["d","note1-d-tag"],["p","5f23c86b8dd9a3a3fd020d5f3f87293ffcba7e66b23437a164ed41f67d75f7ee"],["summary","encrypted-message"]],
          "content":"encrypted-message",
          "sig":"ceb65b126c335f6659769493ae8c309f9061c9cd11dd34d3e0fa606f2e40d9b5bc26f041a26b8ecf124aaa5d0d3438a21761ebc956a10aa576ea67c916696950"}
        ''';

  static const note2 = r'''
          {
          "kind":30023,
          "id":"note2-id",
          "pubkey":"5f23c86b8dd9a3a3fd020d5f3f87293ffcba7e66b23437a164ed41f67d75f7ee",
          "created_at":1750157400,
          "tags":[["client","996e10ba"],["t","996e10ba"],["d","note2-d-tag"],["p","5f23c86b8dd9a3a3fd020d5f3f87293ffcba7e66b23437a164ed41f67d75f7ee"],["summary","encrypted-message"]],
          "content":"encrypted-message",
          "sig":"ceb65b126c335f6659769493ae8c309f9061c9cd11dd34d3e0fa606f2e40d9b5bc26f041a26b8ecf124aaa5d0d3438a21761ebc956a10aa576ea67c916696950"}
        ''';

  static NostrEvent get event1 =>
      NostrEvent.fromJson(jsonDecode(note1) as Map<String, dynamic>);

  static NostrEvent get event2 =>
      NostrEvent.fromJson(jsonDecode(note2) as Map<String, dynamic>);
}
