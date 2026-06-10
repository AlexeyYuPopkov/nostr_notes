import 'dart:convert';

import 'package:common/data/zap/fetch_lightning_donation_usecase.dart';
import 'package:common/data/zap/get_lightning_donation_usecase.dart';
import 'package:common/domain/error/error_messages_provider.dart';
import 'package:common/services/event_store/database/app_database.dart';
import 'package:common/services/event_store/raw_event_store.dart';
import 'package:di_storage/di_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nostr/model/user_keys.dart';
import 'package:nostr/nostr_client/channel_factory.dart';
import 'package:nostr/nostr_client/nostr_client.dart';
import 'package:nostr_notes/app/app_config.dart';
import 'package:nostr_notes/auth/presentation/settings/settings/items/donate_via_lightning/donate_via_lightning.dart';
import 'package:nostr_notes/auth/presentation/settings/settings/items/donate_via_lightning/donate_via_lightning_vm.dart';
import 'package:nostr_notes/common/domain/model/session/session.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';
import 'package:nostr_notes/core/event_kind.dart';
import 'package:uuid/uuid.dart';

import '../../../../../../integration_test/di/in_memory_db_module.dart';
import '../../../../../tools/app_launcher/app_launcher.dart';
import '../../../../../tools/app_launcher/pump_helpers.dart';
import '../../../../../tools/mock_error_messages_provider.dart';
import '../../../../../tools/mock_wschannel.dart';
import '../../../../../tools/mocks/mock_relays_list_repo.dart';
import '../../../../../tools/some_moked_data.dart';

class _MockChannelFactory extends Mock implements ChannelFactory {}

class _MockUuid extends Mock implements Uuid {}

const _eventATag =
    '30023:${SomeMokedData.publicKey}:listing-d-tag:${MockRelaysListRepo.relayUrl1}';
const _eventPubkey = SomeMokedData.publicKey;
const _invoiceEventId = 'invoice-event-id-abc123';
const _payerPubKey =
    'a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2';

String _buildZapEventJson(String subscriptionId) {
  final description = jsonEncode({
    'id': _invoiceEventId,
    'kind': NostrKind.zapInvoice,
    'pubkey': _payerPubKey,
    'tags': [
      ['client', AppConfig.clientTagValue],
      ['amount', '21000'],
    ],
  });

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
  group('DonateViaLightning', () {
    late NostrClient client;
    late _MockChannelFactory channelFactory;
    late MockWSChannel channel;
    late RawEventStore eventStore;
    late AppDatabase db;
    late DonateViaLightningVm vm;

    final mockUuid = _MockUuid();

    setUp(() {
      final di = DiStorage.shared;
      di.bind<ErrorMessagesProvider>(
        () => const MockErrorMessagesProvider(),
        module: null,
        lifeTime: const LifeTime.single(),
      );

      const InMemoryDbModule().bind(di);

      di.bind<SessionUsecase>(
        () => SessionUsecase(),
        module: null,
        lifeTime: const LifeTime.single(),
        onRemove: (e) {
          if (e is SessionUsecase) {
            e.dispose();
          }
        },
      );

      channelFactory = _MockChannelFactory();
      channel = MockWSChannel(url: MockRelaysListRepo.relayUrl1);
      client = NostrClient(channelFactory: channelFactory, uuid: mockUuid);

      db = di.resolve<AppDatabase>();
      eventStore = di.resolve<RawEventStore>();

      vm = DonateViaLightningVm(
        fetchLightningDonationUsecase: FetchLightningDonationUsecase(
          nostrClient: client,
          eventStore: eventStore,
        ),
        getLightningDonationUsecase: GetLightningDonationUsecase(
          eventStore: eventStore,
        ),
      );
    });

    tearDown(() async {
      await vm.disposeAsync();
      await client.disconnectAndDispose();
      await db.close();
      DiStorage.shared.removeAll();
    });

    testWidgets('shows total sats after receiving valid zap receipt', (
      tester,
    ) async {
      final session = DiStorage.shared.resolve<SessionUsecase>();
      session.setSession(
        const Session.auth(UserKeys(publicKey: _payerPubKey, privateKey: '')),
      );

      when(() => mockUuid.v4()).thenReturn('sub-id');
      when(
        () => channelFactory.create(MockRelaysListRepo.relayUrl1),
      ).thenReturn(channel);

      client.addRelay(MockRelaysListRepo.relayUrl1);

      channel.onAdd = (data, ch) {
        if ((data as String).contains('"REQ"')) {
          Future.microtask(() {
            ch.mockStream.add(_buildZapEventJson('sub-id'));
          });
        }
      };

      await tester.pumpWidget(
        AppLauncher.launchApp(
          child: DonateViaLightning(vm: vm, eventPubkey: _eventPubkey),
          tester: tester,
        ),
      );

      expect(find.textContaining('Donate via Lightning'), findsOneWidget);

      await PumpHelpers.waitFor(
        tester,
        find.textContaining('21 sats', findRichText: true),
        reason: 'zap total should appear after receiving the receipt',
      );

      expect(
        find.textContaining('21 sats', findRichText: true),
        findsOneWidget,
      );

      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox.shrink(),
        ),
      );
      await PumpHelpers.pumpFrames(tester, count: 2);
    });
  });
}
