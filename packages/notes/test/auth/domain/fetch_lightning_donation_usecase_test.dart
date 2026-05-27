import 'dart:convert';

import 'package:common/data/zap/fetch_lightning_donation_usecase.dart';
import 'package:common/data/zap/get_lightning_donation_usecase.dart';
import 'package:common/domain/error/error_messages_provider.dart';
import 'package:common/services/event_store/database/app_database.dart';
import 'package:common/services/event_store/raw_event_store.dart';
import 'package:di_storage/di_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nostr/model/nostr_event.dart';
import 'package:nostr/nostr_client/channel_factory.dart';
import 'package:nostr/nostr_client/nostr_client.dart';
import 'package:nostr_notes/core/event_kind.dart';
import 'package:nostr_notes/core/tools/now.dart';
import 'package:uuid/uuid.dart';

import '../../../integration_test/di/in_memory_db_module.dart';
import '../../tools/mock_error_messages_provider.dart';
import '../../tools/mock_wschannel.dart';
import '../../tools/mocks/mock_relays_list_repo.dart';
import '../../tools/some_moked_data.dart';

class _MockChannelFactory extends Mock implements ChannelFactory {}

class _MockUuid extends Mock implements Uuid {}

class _MockNow implements Now {
  @override
  DateTime now() => DateTime(2025, 06, 17, 13, 50);
}

const _eventATag =
    '30023:${SomeMokedData.publicKey}:listing-d-tag:${MockRelaysListRepo.relayUrl1}';
const _eventPubkey = SomeMokedData.publicKey;
const _invoiceEventId = 'invoice-event-id-abc123';
const _payerPubKey =
    'a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2';

String _buildZapEventJson(String subscriptionId) {
  final description = jsonEncode({'id': _invoiceEventId});
  final event = {
    'kind': NostrKind.zapConfirmation,
    'id': 'zap-event-id',
    'pubkey':
        'zapper-pubkey-0000000000000000000000000000000000000000000000000000000000',
    'created_at': 1750157401,
    'tags': [
      ['p', _eventPubkey],
      ['a', _eventATag],
      ['P', _payerPubKey],
      ['description', description],
    ],
    'content': '',
    'sig':
        'sig0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000',
  };
  return '["EVENT","$subscriptionId",${jsonEncode(event)}]';
}

void main() {
  group('FetchLightningDonationUsecase + GetLightningDonationUsecase', () {
    late NostrClient client;
    late _MockChannelFactory channelFactory;
    late MockWSChannel channel;
    late RawEventStore eventStore;

    late FetchLightningDonationUsecase sut1;
    late GetLightningDonationUsecase sut2;

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

      eventStore = di.resolve<RawEventStore>();

      sut1 = FetchLightningDonationUsecase(
        nostrClient: client,
        now: mockNow,
        eventStore: eventStore,
      );

      sut2 = GetLightningDonationUsecase(eventStore: eventStore);
    });

    tearDown(() async {
      await client.disconnectAndDispose();
      await pumpEventQueue();
      final AppDatabase db = DiStorage.shared.resolve();
      await db.close();
      DiStorage.shared.removeAll();
    });

    test(
      'FetchLightningDonationUsecase fetches zapz and ignores invalid zap events from relay.'
      'Bd stores received zap',
      () async {
        when(() => mockUuid.v4()).thenReturn('sub-id');
        when(
          () => channelFactory.create(MockRelaysListRepo.relayUrl1),
        ).thenReturn(channel);

        client.addRelay(MockRelaysListRepo.relayUrl1);

        channel.onAdd = (data, ch) {
          if ((data as String).contains('"REQ"')) {
            Future.microtask(() {
              // Wrong payer pubkey — should be ignored
              final wrongPayer = 'wrong-payer-key';
              final description = jsonEncode({'id': _invoiceEventId});
              final event = jsonEncode({
                'kind': NostrKind.zapConfirmation,
                'id': 'bad-zap-id',
                'pubkey': 'zapper',
                'created_at': 1750157401,
                'tags': [
                  ['p', _eventPubkey],
                  ['a', _eventATag],
                  ['P', wrongPayer],
                  ['description', description],
                ],
                'content': '',
                'sig': 'sig',
              });
              ch.mockStream.add('["EVENT","sub-id",$event]');

              // Then valid event
              Future.microtask(
                () => ch.mockStream.add(_buildZapEventJson('sub-id')),
              );
            });
          }
        };

        final stream = sut1.execute(
          eventATag: _eventATag,
          eventPubkey: _eventPubkey,
          invoiceEventId: _invoiceEventId,
          payerPubKey: _payerPubKey,
        );

        final futureResult = sut2
            .execute(eventATag: _eventATag, eventPubkey: _eventPubkey)
            .where((list) => list.isNotEmpty)
            .first;

        final result = await stream.first;
        expect(result.event.kind, equals(NostrKind.zapConfirmation));
        expect(result.event.getFirstTagStr('P'), equals(_payerPubKey));

        final zaps = await futureResult.timeout(const Duration(seconds: 5));
        expect(zaps, hasLength(1));
        expect(zaps[0].event.id, equals('zap-event-id'));
        expect(zaps[0].event.kind, equals(NostrKind.zapConfirmation));
      },
    );
  });
}
