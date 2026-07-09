import 'dart:async';

import 'package:di_storage/di_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr/model/user_keys.dart';
import 'package:nostr/nostr_client/channel_factory.dart';
import 'package:nostr/nostr_client/nostr_client.dart';
import 'package:nostr_notes/auth/domain/usecase/fetch_notes_usecase.dart';
import 'package:nostr_notes/auth/presentation/notes_list/notes_list.dart';
import 'package:nostr_notes/auth/presentation/notes_list/widgets/notes_list_card.dart';
import 'package:nostr_notes/auth/presentation/widgets/new_note_prompt_placeholder.dart';
import 'package:nostr_notes/common/domain/model/session/session.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';
import 'package:nostr_notes/common/presentation/shimmers/common_shimmer_placeholder.dart';
import 'package:nostr_notes/core/tools/now.dart';
import 'package:nostr_notes/services/crypto_service/crypto_service.dart';
import 'package:common/services/event_store/database/app_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:uuid/uuid.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../integration_test/di/in_memory_db_module.dart';
import '../../../../integration_test/di/test_app_di_overrides_proxy.dart';
import '../../../tools/app_launcher/app_launcher.dart';

import '../../../tools/mock_wschannel.dart';

class MockUuid extends Mock implements Uuid {}

final class _TestNotesListCoordinator implements NotesListCoordinator {
  const _TestNotesListCoordinator();

  @override
  FutureOr<dynamic> onNotePreviewRoute(
    BuildContext context, {
    required String noteId,
  }) {}

  @override
  void onNewNoteRoute(BuildContext context) {}

  @override
  void onEndDrawer() {}

  @override
  void onAccountSwitcher() {}

  @override
  void onAddAccountRoute(BuildContext context) {}
}

class MockChannelFactory extends Mock implements ChannelFactory {}

class MockNow implements Now {
  @override
  DateTime now() => DateTime(2026, 21, 3);
}

void main() {
  late MockUuid mockUuid;
  late MockWSChannel relayChannel;
  late MockChannelFactory channelFactory;
  late NostrClient relayClient;
  late FetchNotesUsecase fetchNotesUsecase;

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

    fetchNotesUsecase = FetchNotesUsecase(
      notesRepository: di.resolve(),
      sessionUsecase: di.resolve(),
      relaysListRepo: di.resolve(),
      now: MockNow(),
    );

    di.remove<FetchNotesUsecase>();
    di.bind<FetchNotesUsecase>(
      () => fetchNotesUsecase,
      module: null,
      lifeTime: const LifeTime.prototype(),
    );
  });

  tearDown(() async {
    relayClient.disconnectAndDispose();

    final db = DiStorage.shared.resolve<AppDatabase>();

    DiStorage.shared.removeAll();
    await db.close();
  });

  group('NotesList', () {
    testWidgets('NotesList - empty state', (tester) async {
      tester.view.physicalSize = _Helper.iPhoneSize;
      tester.view.devicePixelRatio = _Helper.devicePixelRatio;
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
          child: const NotesList(
            selectedNoteDTag: '',
            coordinator: _TestNotesListCoordinator(),
          ),
        ),
      );

      expect(find.byType(NotesList), findsOneWidget);

      expect(find.byType(CommonShimmer), findsWidgets);

      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.byType(NewNotePromptPlaceholder), findsOneWidget);
      expect(find.byType(CommonShimmer), findsNothing);
      await tester.pumpAndSettle();

      // Close database
      await tester.pump();
      final di = DiStorage.shared;

      final db = di.resolve<AppDatabase>();
      await db.close();
      await tester.pump();

      // await session.dispose();

      await tester.pumpWidget(Container());
      await tester.pumpAndSettle();
    });

    testWidgets('NotesList - notes', (tester) async {
      final di = DiStorage.shared;
      tester.view.physicalSize = _Helper.iPhoneSize;
      tester.view.devicePixelRatio = _Helper.devicePixelRatio;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final SessionUsecase session = DiStorage.shared.resolve();
      session.setSession(const Unlocked(keys: _Helper.keys, pin: _Helper.pin));

      when(
        () => mockUuid.v4(),
      ).thenReturn('f5996f40-6622-11f0-b6aa-77622cb064581');
      when(
        () => channelFactory.create('wss://test.relay'),
      ).thenReturn(relayChannel);

      // final requests = <String>[];

      relayChannel.onAdd = (data, channel) {
        const req =
            r'["REQ",'
            '"f5996f40-6622-11f0-b6aa-77622cb064581",'
            '{"kinds":[30023],'
            '"authors":["bfea1ad2fdbbdd4c6d2419b3d4f63f09ad8a94d5835a7f97453eb93e860ea8fe"],'
            '"#t":["996e10ba"],'
            '"#p":["bfea1ad2fdbbdd4c6d2419b3d4f63f09ad8a94d5835a7f97453eb93e860ea8fe"],'
            '"until":1819918800},'
            '{"kinds":[5],'
            '"authors":["bfea1ad2fdbbdd4c6d2419b3d4f63f09ad8a94d5835a7f97453eb93e860ea8fe"],'
            '"until":1819918800,'
            '"#k":["30023"]}]';

        if (data is String && data == req) {
          // Future.microtask гарантирует что события придут ПОСЛЕ того как
          // eventsStream.listen() уже вызван и подписчик зарегистрирован
          // в NostrRelay._controller.broadcast(). Без этого события теряются,
          // т.к. broadcast() не буферизует и события уходят в никуда.
          Future.microtask(() {
            channel.mockStream.add(_TestEvents.note5);
            channel.mockStream.add(_TestEvents.note4);
            channel.mockStream.add(_TestEvents.note3);
            channel.mockStream.add(_TestEvents.note2);
            channel.mockStream.add(_TestEvents.note1);

            channel.mockStream.add(
              '["EOSE","f5996f40-6622-11f0-b6aa-77622cb064581"]',
            );
          });
        }
      };

      await tester.pumpWidget(
        AppLauncher.launchApp(
          tester: tester,
          child: const NotesList(
            selectedNoteDTag: '',
            coordinator: _TestNotesListCoordinator(),
          ),
        ),
      );

      expect(find.byType(NotesList), findsOneWidget);

      expect(find.byType(CommonShimmer), findsWidgets);

      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 500));

      await expectLater(find.byType(NotesListCard), findsWidgets);

      // Close database
      await tester.pump();

      final db = di.resolve<AppDatabase>();
      await db.close();
      await tester.pump();
    }, skip: false);
  });
}

/// Test event JSON strings for mock relay responses
final class _TestEvents {
  static const note1 = r'''["EVENT", "f5996f40-6622-11f0-b6aa-77622cb064581",
    {
        "content": "AtfebdJN/dW8bGeY/wu716HmFK/CrmSdF2BIxgoJz+maKO8US3RWKhRM7MCwwl5smKsmWzoBqH53bBpEsqjoykE+TxeifgHJajCSVKa1DtVyiFyifXQYf+pXXG3LbQpKj85U",
        "created_at": 1774099539,
        "id": "c68352568e2dc5c19c3709be52a5c4b745fe960dc98c9431ed677a0201ffd63c",
        "kind": 30023,
        "pubkey": "bfea1ad2fdbbdd4c6d2419b3d4f63f09ad8a94d5835a7f97453eb93e860ea8fe",
        "sig": "557e3fd2c932d2b5c5b208687af83c3806d873940462edcd21acee3c4f158a29044340e4bd730fb035d87b95b9e2a6049ed537e47bffc348286d73c294713159",
        "tags": [
            [
                "client",
                "996e10ba"
            ],
            [
                "t",
                "996e10ba"
            ],
            [
                "d",
                "73d5e300-2529-11f1-a529-611a9024e8ba"
            ],
            [
                "p",
                "bfea1ad2fdbbdd4c6d2419b3d4f63f09ad8a94d5835a7f97453eb93e860ea8fe"
            ],
            [
                "summary",
                "ArxSP2z6YfrygW7GSPHSJfvY+YYtRLgyps+x3W4F+rsry/TvCrfWwD78U7G7Tz8WpOxHw23RTyi536CRmezctA28xhrmCEKEFjDjX6TAQXdV2zMMUXH4fOIaCcR6VGB7qS8Z"
            ]
        ]
    }
]''';
  static const note2 = r'''["EVENT", "f5996f40-6622-11f0-b6aa-77622cb064581",
    {
        "content": "AnBDYoYvirASAnBehxrz7iYnuB0DiaNs0M2KW3NpZ+tYUz0XdEh1er8suk6n7dN89lJyCM8NMnBvZgkuR9hqT58RymuLzF8yKbu15XGLgp37SNoWUG9S6+IJowaKszKbMke7",
        "created_at": 1774099553,
        "id": "7fc7aa257333c23844016fb319d127b7d3e45bc038182313e37fdf7541f205f6",
        "kind": 30023,
        "pubkey": "bfea1ad2fdbbdd4c6d2419b3d4f63f09ad8a94d5835a7f97453eb93e860ea8fe",
        "sig": "c1376f32c3009aecc991057d2fe8e3072dc89d00ab9f7fbbacfa6c68b86ddeaf1133706614b3763da85c5114e14fd3ee0c8f1341ba9b54dd7cdaecdac5752336",
        "tags": [
            [
                "client",
                "996e10ba"
            ],
            [
                "t",
                "996e10ba"
            ],
            [
                "d",
                "7c56dbb0-2529-11f1-a529-611a9024e8ba"
            ],
            [
                "p",
                "bfea1ad2fdbbdd4c6d2419b3d4f63f09ad8a94d5835a7f97453eb93e860ea8fe"
            ],
            [
                "summary",
                "AvJDg8EvwZUN3Kte8DnsTSkI5grmeRF0vKC/NOmDROIYV67qFQSkqKiT87UQMXXCOOpvjyt5NjI61D5hVKsPAwZPbiIrlXXlwR5U1witfSO/dnRv/K/k/EhIl3AJYyTPP6K5"
            ]
        ]
    }
]
''';

  static const note3 = r'''["EVENT", "f5996f40-6622-11f0-b6aa-77622cb064581",
    {
        "content": "AoTMkn/AFfdaXiqN09+V3pI0NKflXMZHmaVIozHa4XlcUXPxnePLmkV2PhtJPSMo73hpcelR5AzaXQby6biNNIGmLz8argfKZwflOKZNfPrmTZCirklFgz+8D/FAcd3iugvZ",
        "created_at": 1774099568,
        "id": "d890eddbca390c06952b22d81afd7d9697764ff71fabe4507231bcae9903c410",
        "kind": 30023,
        "pubkey": "bfea1ad2fdbbdd4c6d2419b3d4f63f09ad8a94d5835a7f97453eb93e860ea8fe",
        "sig": "213a49be3ac06d3fe3530e9ca9f279afe7789d66d0d5779aca414257432765f44ddc334d623ea7a67ab26e11322eeb6e7b1e8fa6d1365580bbbd5e3a81056bf7",
        "tags": [
            [
                "client",
                "996e10ba"
            ],
            [
                "t",
                "996e10ba"
            ],
            [
                "d",
                "85216080-2529-11f1-a529-611a9024e8ba"
            ],
            [
                "p",
                "bfea1ad2fdbbdd4c6d2419b3d4f63f09ad8a94d5835a7f97453eb93e860ea8fe"
            ],
            [
                "summary",
                "AtL0Ot4ifkf4CV3jT/EWSxhjekB03uVzyrUORIAbAb1FASLI05BTHeaw3a8T9SLCdJYeGFPb9GCIi+/W1rhnDqyQpD/zDlhHmE+xQQGLvDwJGgmEkEHpWxqts0box42nALIr"
            ]
        ]
    }
]
''';
  static const note4 = r'''["EVENT", "f5996f40-6622-11f0-b6aa-77622cb064581",
    {
        "content": "AuQetok3pPKTgmMiImsb1LxqpiQbiqLO1LIxO6Tmy3ekZwC1MH/bT2GS8DY2f4+LTNZm7bH1fUW29GFM2X4MDyRzfYZ+CHZC20GZXnp9JJBiB7FopSiklNMCQCNpQWNii5Ku",
        "created_at": 1774099609,
        "id": "5e69bec09fbdc24de95f0dc4c9ae17ee5b122b01e5fdc19f7fb2b4df5c7d16db",
        "kind": 30023,
        "pubkey": "bfea1ad2fdbbdd4c6d2419b3d4f63f09ad8a94d5835a7f97453eb93e860ea8fe",
        "sig": "74dfe0afbc5aa16c553ba2feda603d9f647985a642bf6ddb9aacd51b0d647f7a7f3b2738ad9ba062a3aafa1badd62b8088d0cae7d1f698eb7354ecff76c10324",
        "tags": [
            [
                "client",
                "996e10ba"
            ],
            [
                "t",
                "996e10ba"
            ],
            [
                "d",
                "9d8238c0-2529-11f1-a529-611a9024e8ba"
            ],
            [
                "p",
                "bfea1ad2fdbbdd4c6d2419b3d4f63f09ad8a94d5835a7f97453eb93e860ea8fe"
            ],
            [
                "summary",
                "AleRjVx/T30TaU8MJwkwYTC4rWk+jsAw4x/FmHL7UMI/l0iMHtCa9IoTUm1bY9FT6uN7kzOBFsOd8lqMLRmnVnePrKSuJ9CX5J0+SRIeByfqPef2Y9QrzIi9q660OvpG5rMl"
            ]
        ]
    }
]
''';
  static const note5 = r'''["EVENT", "f5996f40-6622-11f0-b6aa-77622cb064581",
    {
        "content": "AluXwtVHySypJ8hFXkqjZ/pP453uBnDUgBHGfUhTsyOvssDWe9OcOIfO218lVb8yiOdp+xtCYDGuepbu+M5zUePyw4y4Azp1Y63XfN8bUrlbaji5hVzH769s5EOXjN838SKN",
        "created_at": 1774099643,
        "id": "9e921546ff24491b5eba67f8f79766b477a3b2c1804f80cb2b4e8381944e03d2",
        "kind": 30023,
        "pubkey": "bfea1ad2fdbbdd4c6d2419b3d4f63f09ad8a94d5835a7f97453eb93e860ea8fe",
        "sig": "61d95981dd2f976dd5344eaf309f71e62996180013cfa65c1b7ac13f6edd108c6c25f010e0ca37221796674565d9d5da8bc45497ad8c74d8497d9fd9f06867e8",
        "tags": [
            [
                "client",
                "996e10ba"
            ],
            [
                "t",
                "996e10ba"
            ],
            [
                "d",
                "b2178a10-2529-11f1-a529-611a9024e8ba"
            ],
            [
                "p",
                "bfea1ad2fdbbdd4c6d2419b3d4f63f09ad8a94d5835a7f97453eb93e860ea8fe"
            ],
            [
                "summary",
                "Al3ylgDoFOTJjebXwCR3h+bSqiB4daZ7/3VH+thINGyeDYujFplM1BusSlcQcAQLEgKR8sMmZN7AgFqFB+Wzs/xIr7D8wz+A56yOk6Cm9TTLuWC0mHBO8Wrx+AAYbJZir3z+"
            ]
        ]
    }
]
''';
}

final class _Helper {
  static const iPhoneSize = Size(1170, 2532); // 390*3, 844*3
  static const devicePixelRatio = 3.0;
  // nsec1a7er5pe4xt3glreu7xem5j7f9udmd26d6djus572h7dhqpzwxfqqht6uzj
  static const keys = UserKeys(
    publicKey:
        'bfea1ad2fdbbdd4c6d2419b3d4f63f09ad8a94d5835a7f97453eb93e860ea8fe',
    privateKey:
        'efb23a073532e28f8f3cf1b3ba4bc92f1bb6ab4dd365c853cabf9b70044e3240',
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
