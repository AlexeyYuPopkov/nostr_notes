import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_notes/auth/domain/usecase/create_note_usecase.dart';
import 'package:nostr_notes/auth/domain/repo/relays_list_repo.dart';
import 'package:nostr_notes/common/data/event_publisher_impl.dart';
import 'package:nostr_notes/common/domain/event_publisher.dart';
import 'package:nostr_notes/common/domain/model/session/session.dart';
import 'package:nostr_notes/common/domain/model/session/user_keys.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';
import 'package:nostr_notes/services/channel_factory.dart';
import 'package:nostr_notes/services/key_tool/nip04_service.dart';
import 'package:nostr_notes/services/nostr_client.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nostr_notes/services/ws_channel.dart';
import 'package:nostr_notes/core/tools/now.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

import '../../tools/some_moked_data.dart';

// class MockWSChannel extends Mock implements WsChannel {}
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

class MockNip04Service extends Mock implements Nip04Service {}

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
    final mockNip04Service = MockNip04Service();

    setUp(() {
      channelFactory = MockChannelFactory();
      channel1 = MockWSChannel(url: MockRelaysListRepo.relayUrl1);
      channel2 = MockWSChannel(url: MockRelaysListRepo.relayUrl2);
      client = NostrClient(channelFactory: channelFactory);

      sut = CreateNoteUsecase(
        sessionUsecase: SessionUsecase()
          ..setSession(
            const Unlocked(
              keys: UserKeys(
                publicKey: SomeMokedData.publicKey,
                privateKey: SomeMokedData.privateKey,
              ),
              pin: '1234',
            ),
          ),
        eventPublisher: EventPublisherImpl(
          nostrClient: client,
          relaysListRepo: const MockRelaysListRepo(),
          nip04: mockNip04Service,
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
        ["OK","def6550b2414613e6c4ead1a0d2db0da322713d499977f5e0e0b90fcf21e2e39",true,""]
        ''';

      channel1.onAdd = (data, channel) {
        channel.mockStream.add(responce);
      };

      channel2.onAdd = (data, channel) {
        channel.mockStream.add(responce);
      };

      when(
        () => mockNip04Service.encryptNip04(
          content: 'message',
          peerPubkey: SomeMokedData.publicKey,
          privateKey: SomeMokedData.privateKey,
        ),
      ).thenReturn('encrypted-message');

      when(
        () => mockNip04Service.decryptNip04(
          content: 'encrypted-message',
          peerPubkey: SomeMokedData.publicKey,
          privateKey: SomeMokedData.privateKey,
        ),
      ).thenReturn('message');

      final result = await sut.execute(
        content: 'message',
        dTag: null,
        now: mockNow,
        uuid: mockUuid,
        randomBytes: SomeMokedData.randomBytes,
      );

      expect(result, isA<EventPublisherResult>());
      expect(result.timeoutError == null, true);
      expect(result.reports.length, 2);
      expect(result.reports[0].errorMessage, '');
      expect(result.reports[1].errorMessage, '');

      const sendedEvent = r'''
          ["EVENT",{
          "kind":4,
          "id":"def6550b2414613e6c4ead1a0d2db0da322713d499977f5e0e0b90fcf21e2e39",
          "pubkey":"5f23c86b8dd9a3a3fd020d5f3f87293ffcba7e66b23437a164ed41f67d75f7ee",
          "created_at":1750157400,
          "tags":[["client","996e10ba"],["t","996e10ba"],["d","uuid-v1"],["p","5f23c86b8dd9a3a3fd020d5f3f87293ffcba7e66b23437a164ed41f67d75f7ee"]],
          "content":"encrypted-message",
          "sig":"bc54ad2f218b2baa36a13adadcfeda5b4d71950164e8f858c218806b19d0f90f3d34f3ccb3b7e368ece2447e26f95c2d58e03b4d4a2bf23f02b361b7751dd2e1"}]
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
        ["OK","def6550b2414613e6c4ead1a0d2db0da322713d499977f5e0e0b90fcf21e2e39",true,""]
        ''';
      channel1.onAdd = (data, channel) {
        channel.mockStream.add(responce);
      };

      when(
        () => mockNip04Service.encryptNip04(
          content: 'message',
          peerPubkey: SomeMokedData.publicKey,
          privateKey: SomeMokedData.privateKey,
        ),
      ).thenReturn('encrypted-message');

      when(
        () => mockNip04Service.decryptNip04(
          content: 'encrypted-message',
          peerPubkey: SomeMokedData.publicKey,
          privateKey: SomeMokedData.privateKey,
        ),
      ).thenReturn('message');

      final result = await sut.execute(
        content: 'message',
        dTag: null,
        now: mockNow,
        uuid: mockUuid,
        randomBytes: SomeMokedData.randomBytes,
      );

      expect(result, isA<EventPublisherResult>());
      expect(result.timeoutError, isA<PublishTimeoutError>());
      expect(result.reports.length, 1);
      expect(result.reports[0].errorMessage, '');

      const sendedEvent = r'''
          ["EVENT",{
          "kind":4,
          "id":"def6550b2414613e6c4ead1a0d2db0da322713d499977f5e0e0b90fcf21e2e39",
          "pubkey":"5f23c86b8dd9a3a3fd020d5f3f87293ffcba7e66b23437a164ed41f67d75f7ee",
          "created_at":1750157400,
          "tags":[["client","996e10ba"],["t","996e10ba"],["d","uuid-v1"],["p","5f23c86b8dd9a3a3fd020d5f3f87293ffcba7e66b23437a164ed41f67d75f7ee"]],
          "content":"encrypted-message",
          "sig":"bc54ad2f218b2baa36a13adadcfeda5b4d71950164e8f858c218806b19d0f90f3d34f3ccb3b7e368ece2447e26f95c2d58e03b4d4a2bf23f02b361b7751dd2e1"}]
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
