import 'dart:async';
import 'dart:convert';

import 'package:di_storage/di_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_notes/auth/data/common_event_storage_impl.dart';
import 'package:nostr_notes/auth/data/notes_repository_impl.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/auth/domain/repo/crypto_algorithm_type.dart';
import 'package:nostr_notes/auth/domain/repo/crypto_repo.dart';
import 'package:nostr_notes/auth/domain/usecase/create_note_usecase.dart';
import 'package:nostr_notes/auth/domain/repo/relays_list_repo.dart';
import 'package:nostr_notes/auth/domain/usecase/note_crypto_use_case.dart';
import 'package:nostr_notes/common/domain/error/error_messages_provider.dart';
import 'package:nostr_notes/common/domain/event_publisher.dart';
import 'package:nostr_notes/common/domain/model/session/session.dart';
import 'package:nostr_notes/common/domain/model/session/user_keys.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';
import 'package:nostr_notes/services/channel_factory.dart';
import 'package:nostr_notes/services/nostr_client.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nostr_notes/services/ws_channel.dart';
import 'package:nostr_notes/core/tools/now.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

import '../../tools/mock_error_messages_provider.dart';
import '../../tools/some_moked_data.dart';

final class MockWSChannel implements WsChannel {
  final String _url;

  final List<Map<String, dynamic>> calls = [];

  void Function(dynamic data, MockWSChannel channel)? onAdd;

  MockWSChannel({
    required String url,
  }) : _url = url;

  final mockStream = PublishSubject<String>();

  @override
  void add(data) {
    calls.add({'add': data});
    onAdd?.call(data, this);
  }

  @override
  Future disconnect() async {
    calls.add({'disconnect': ''});
  }

  @override
  Future<void> get ready async {
    calls.add({'ready': ''});
  }

  @override
  Stream get stream {
    calls.add({'stream': ''});
    return mockStream;
  }

  @override
  String get url {
    calls.add({'url': ''});
    return _url;
  }
}

class MockChannelFactory extends Mock implements ChannelFactory {}

class MockUuid extends Mock implements Uuid {}

class MockCryptoRepo implements CryptoRepo {
  @override
  FutureOr<CryptoAlgorithmType> createCache(
      {required CryptoAlgorithmType algorithmType}) {
    return const CryptoAlgorithmType.nip44(
      privateKey: '',
      peerPubkey: '',
    );
  }

  @override
  FutureOr<String> decryptMessage(
      {required String text, required CryptoAlgorithmType algorithmType}) {
    return 'message';
  }

  @override
  FutureOr<String> encryptMessage(
      {required String text, required CryptoAlgorithmType algorithmType}) {
    return 'encrypted-message';
  }
}

class MockNow implements Now {
  @override
  DateTime now() {
    return DateTime(2025, 06, 17, 13, 50);
  }
}

class MockRelaysListRepo implements RelaysListRepo {
  static const relayUrl1 = 'wss://relay1.example.com';
  static const relayUrl2 = 'wss://relay2.example.com';

  const MockRelaysListRepo();

  @override
  List<String> getRelaysList() {
    return [
      relayUrl1,
      relayUrl2,
    ];
  }
}

void main() {
  group('CreateNoteUsecase', () {
    late NostrClient client;
    late MockChannelFactory channelFactory;
    late MockWSChannel channel1;
    late MockWSChannel channel2;

    late CreateNoteUsecase sut;
    final mockNow = MockNow();
    final mockUuid = MockUuid();
    final mockCryptoRepo = MockCryptoRepo();

    setUp(() {
      DiStorage.shared.bind<ErrorMessagesProvider>(
        () => const MockErrorMessagesProvider(),
        module: null,
        lifeTime: const LifeTime.single(),
      );
      channelFactory = MockChannelFactory();
      channel1 = MockWSChannel(url: MockRelaysListRepo.relayUrl1);
      channel2 = MockWSChannel(url: MockRelaysListRepo.relayUrl2);
      client = NostrClient(channelFactory: channelFactory);

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

      sut = CreateNoteUsecase(
        sessionUsecase: sessionUsecase,
        // eventPublisher: EventPublisherImpl(
        //   nostrClient: client,
        //   relaysListRepo: const MockRelaysListRepo(),
        // ),
        noteCryptoUseCase: NoteCryptoUseCase(
          sessionUsecase: sessionUsecase,
          cryptoRepo: mockCryptoRepo,
        ),
        notesRepository: NotesRepositoryImpl(
          client: client,
          memoryStorage: CommonEventStorageImpl(),
          relaysListRepo: const MockRelaysListRepo(),
        ),
      );
    });

    tearDown(() async {
      await client.disconnect();
    });

    test('successful note creation', () async {
      when(() => mockUuid.v1()).thenReturn('uuid-v1');
      when(() => channelFactory.create(MockRelaysListRepo.relayUrl1))
          .thenReturn(channel1);
      when(() => channelFactory.create(MockRelaysListRepo.relayUrl2))
          .thenReturn(channel2);

      const responce = r'''
        ["OK","9d1c1d765e572b5914ed838cba42bb22b9fb50f5ac0532c494caf75bc7363143",true,""]
        ''';

      channel1.onAdd = (data, channel) {
        channel.mockStream.add(responce);
      };

      channel2.onAdd = (data, channel) {
        channel.mockStream.add(responce);
      };

      final result = await sut.execute(
        content: 'message',
        dTag: null,
        now: mockNow,
        uuid: mockUuid,
        randomBytes: SomeMokedData.randomBytes,
      );

      expect(result, isA<EventPublisherResult>());
      expect(result.targetNote is Note, true);
      expect(result.reports.length, 2);
      expect(result.reports[0].errorMessage, '');
      expect(result.reports[1].errorMessage, '');

      const sendedEvent = r'''
          ["EVENT",{
          "kind":30023,
          "id":"9d1c1d765e572b5914ed838cba42bb22b9fb50f5ac0532c494caf75bc7363143",
          "pubkey":"5f23c86b8dd9a3a3fd020d5f3f87293ffcba7e66b23437a164ed41f67d75f7ee",
          "created_at":1750157400,
          "tags":[["client","996e10ba"],["t","996e10ba"],["d","uuid-v1"],["p","5f23c86b8dd9a3a3fd020d5f3f87293ffcba7e66b23437a164ed41f67d75f7ee"],["summary","encrypted-message"]],
          "content":"encrypted-message",
          "sig":"ceb65b126c335f6659769493ae8c309f9061c9cd11dd34d3e0fa606f2e40d9b5bc26f041a26b8ecf124aaa5d0d3438a21761ebc956a10aa576ea67c916696950"}]
        ''';

      expect(channel1.calls.length, 6);
      expect(channel1.calls, equals(channel2.calls));
      expect(channel1.calls[0], {'ready': ''});
      expect(channel1.calls[1], {'stream': ''});
      expect(channel1.calls[2], {'url': ''});
      expect(
        jsonDecode(channel1.calls[3]['add']),
        jsonDecode(sendedEvent),
      );
    });

    test(
        'successful note creation on 1nd relay from 2 and no responce from 2nd relay',
        () async {
      when(() => mockUuid.v1()).thenReturn('uuid-v1');
      when(() => channelFactory.create(MockRelaysListRepo.relayUrl1))
          .thenReturn(channel1);
      when(() => channelFactory.create(MockRelaysListRepo.relayUrl2))
          .thenReturn(channel2);

      const responce = r'''
        ["OK","9d1c1d765e572b5914ed838cba42bb22b9fb50f5ac0532c494caf75bc7363143",true,""]
        ''';
      channel1.onAdd = (data, channel) {
        channel.mockStream.add(responce);
      };

      final result = await sut.execute(
        content: 'message',
        dTag: null,
        now: mockNow,
        uuid: mockUuid,
        randomBytes: SomeMokedData.randomBytes,
      );

      expect(result, isA<EventPublisherResult>());
      expect(result.error, isA<PublishTimeoutError>());
      expect(result.reports.length, 1);
      expect(result.reports[0].errorMessage, '');

      const sendedEvent = r'''
          ["EVENT",{
          "kind":30023,
          "id":"9d1c1d765e572b5914ed838cba42bb22b9fb50f5ac0532c494caf75bc7363143",
          "pubkey":"5f23c86b8dd9a3a3fd020d5f3f87293ffcba7e66b23437a164ed41f67d75f7ee",
          "created_at":1750157400,
          "tags":[["client","996e10ba"],["t","996e10ba"],["d","uuid-v1"],["p","5f23c86b8dd9a3a3fd020d5f3f87293ffcba7e66b23437a164ed41f67d75f7ee"],["summary","encrypted-message"]],
          "content":"encrypted-message",
          "sig":"ceb65b126c335f6659769493ae8c309f9061c9cd11dd34d3e0fa606f2e40d9b5bc26f041a26b8ecf124aaa5d0d3438a21761ebc956a10aa576ea67c916696950"}]
        ''';

      expect(channel1.calls.length, 6);
      expect(channel2.calls.length, 5);
      expect(channel1.calls[0], {'ready': ''});
      expect(channel1.calls[1], {'stream': ''});
      expect(channel1.calls[2], {'url': ''});
      expect(
        jsonDecode(channel1.calls[3]['add']),
        jsonDecode(sendedEvent),
      );
    });
  });
}
