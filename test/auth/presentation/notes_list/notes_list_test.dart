import 'package:di_storage/di_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_notes/auth/domain/repo/relays_list_repo.dart';
import 'package:nostr_notes/auth/presentation/notes_list/notes_list.dart';
import 'package:nostr_notes/auth/presentation/widgets/new_note_prompt_placeholder.dart';
import 'package:nostr_notes/common/domain/model/session/session.dart';
import 'package:nostr_notes/common/domain/model/session/user_keys.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';
import 'package:nostr_notes/common/presentation/shimmers/common_shimmer_placeholder.dart';
import 'package:nostr_notes/services/crypto_service/crypto_service.dart';
import 'package:nostr_notes/services/event_store/database/app_database.dart';
import 'package:nostr_notes/services/nostr_client/channel_factory.dart';
import 'package:nostr_notes/services/nostr_client/nostr_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:uuid/uuid.dart';
import 'package:mocktail/mocktail.dart';

import '../../../tools/app_launcher/app_launcher.dart';
import '../../../tools/di/in_memory_db_module.dart';
import '../../../tools/di/test_app_di_overrides_proxy.dart';
import '../../../tools/mock_wschannel.dart';

class MockUuid extends Mock implements Uuid {}

class MockChannelFactory extends Mock implements ChannelFactory {}

void main() {
  late MockUuid mockUuid;
  late MockWSChannel relayChannel;
  late MockChannelFactory channelFactory;
  late NostrClient relayClient;

  setUp(() async {
    mockUuid = MockUuid();

    relayChannel = MockWSChannel(url: 'wss://test.relay');
    channelFactory = MockChannelFactory();
    relayClient = NostrClient(channelFactory: channelFactory, uuid: mockUuid);

    SharedPreferences.setMockInitialValues({
      'relay_urls': ['wss://test.relay'],
    });

    final di = DiStorage.shared;
    const InMemoryDbModule().bind(di);

    await const TestAppDiOverridesProxy().bindUnauthModules();
    await const TestAppDiOverridesProxy().bindAuthModules();

    di.bind<NostrClient>(
      () => relayClient,
      module: null,
      lifeTime: const LifeTime.prototype(),
    );

    final CryptoService cryptoService = di.resolve();
    await cryptoService.init();
  });

  tearDown(() async {
    relayClient.disconnectAndDispose();

    final db = DiStorage.shared.resolve<AppDatabase>();

    DiStorage.shared.removeAll();
    await db.close();
  });

  group('NotesList', () {
    testWidgets('NotesList - empty state', (tester) async {
      tester.view.physicalSize = const Size(1170, 2532); // 390*3, 844*3
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final SessionUsecase session = DiStorage.shared.resolve();
      session.setSession(const Unlocked(keys: _Helper.keys, pin: _Helper.pin));

      when(() => mockUuid.v4()).thenReturn('uuid-v4');
      when(
        () => channelFactory.create('wss://test.relay'),
      ).thenReturn(relayChannel);

      final requests = <String>[];
      relayChannel.onAdd = (data, channel) {
        const req =
            r'["REQ",'
            '"uuid-v4",'
            '{"kinds":[30023],'
            '"authors":["efb23a073532e28f8f3cf1b3ba4bc92f1bb6ab4dd365c853cabf9b70044e3240"],'
            '"#t":["996e10ba"],'
            '"#p":["efb23a073532e28f8f3cf1b3ba4bc92f1bb6ab4dd365c853cabf9b70044e3240"],'
            '"until":1774083847},'
            '{"kinds":[5],'
            '"authors":["efb23a073532e28f8f3cf1b3ba4bc92f1bb6ab4dd365c853cabf9b70044e3240"],'
            '"until":1774083847,'
            '"#k":["30023"]}]';

        if (data is String && data == req) {
          requests.add(data);
          channel.mockStream.add('["EOSE","uuid-v4"]');
        }
      };

      await tester.pumpWidget(
        AppLauncher.launchApp(
          tester: tester,
          child: NotesList(selectedNoteDTag: '', onTap: (note) {}),
        ),
      );

      expect(find.byType(NotesList), findsOneWidget);

      expect(find.byType(CommonShimmer), findsWidgets);

      // final helper = _Helper();
      // final bloc = helper.bloc(tester);

      // // Wait for initial settling
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.byType(NewNotePromptPlaceholder), findsOneWidget);
      expect(find.byType(CommonShimmer), findsNothing);
      await tester.pumpAndSettle();
      // Close database
      await tester.pump();
      final di = DiStorage.shared;

      final CryptoService cryptoService = di.resolve();
      await cryptoService.dispose();

      final RelaysListRepo relaysListRepo = di.resolve();
      await relaysListRepo.dispose();

      // await relayClient.disconnectAndDispose();

      // final publisher = di.resolve<OutboxPublisher>();
      // await publisher.dispose();

      final db = di.resolve<AppDatabase>();
      await db.close();
      await tester.pump();

      await session.dispose();

      await tester.pumpWidget(Container());
      await tester.pumpAndSettle();
    });
  });
}

/// Test event JSON strings for mock relay responses
// final class _TestEvents {}

final class _Helper {
  static const keys = UserKeys(
    publicKey:
        'efb23a073532e28f8f3cf1b3ba4bc92f1bb6ab4dd365c853cabf9b70044e3240',
    privateKey:
        'bfea1ad2fdbbdd4c6d2419b3d4f63f09ad8a94d5835a7f97453eb93e860ea8fe',
  );
  static const pin = '1234';
  // late final screen = find.byType(ChatRoomsList);

  // ChatRoomsBloc bloc(WidgetTester tester) =>
  //     tester.element(firstBlocConsumer).read<ChatRoomsBloc>();

  // late final firstBlocConsumer = find.descendant(
  //   of: screen,
  //   matching: find.byType(BlocBuilder<ChatRoomsBloc, ChatRoomsState>).first,
  // );
}
