import 'package:di_storage/di_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr/model/user_keys.dart';
import 'package:nostr/nostr_client/channel_factory.dart';
import 'package:nostr/nostr_client/nostr_client.dart';
import 'package:nostr_notes/auth/domain/usecase/fetch_notes_usecase.dart';
import 'package:nostr_notes/auth/presentation/model/path_params.dart';
import 'package:nostr_notes/auth/presentation/note_screen/note_preview_screen/note_preview_screen.dart';
import 'package:nostr_notes/common/domain/model/session/session.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';
import 'package:nostr_notes/core/tools/now.dart';
import 'package:nostr_notes/services/crypto_service/crypto_service.dart';
import 'package:common/services/event_store/database/app_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:mocktail/mocktail.dart';

import '../../../integration_test/di/in_memory_db_module.dart';
import '../../../integration_test/di/test_app_di_overrides_proxy.dart';
import '../../tools/app_launcher/app_launcher.dart';
import '../../tools/mock_wschannel.dart';

class MockUuid extends Mock implements Uuid {}

class MockChannelFactory extends Mock implements ChannelFactory {}

class MockNow implements Now {
  @override
  DateTime now() => DateTime(2026, 21, 3);
}

final class _FakeNotePreviewCoordinator
    implements NotePreviewScreenCoordinator {
  const _FakeNotePreviewCoordinator();

  @override
  void onCreateNoteRoute(BuildContext context) {}

  @override
  void onRawEventRoute(BuildContext context, {required String eventId}) {}
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

  group('NotePreviewScreen', () {
    testWidgets('renders in loading state', (tester) async {
      final SessionUsecase session = DiStorage.shared.resolve();
      session.setSession(const Unlocked(keys: _Helper.keys, pin: _Helper.pin));

      when(() => mockUuid.v4()).thenReturn('uuid-v4');
      when(
        () => channelFactory.create('wss://test.relay'),
      ).thenReturn(relayChannel);

      await tester.pumpWidget(
        AppLauncher.launchApp(
          tester: tester,
          child: NotePreviewScreen(
            pathParams: const PathParams(id: _TestEvents.noteDTag),
            coordinator: const _FakeNotePreviewCoordinator(),
            onEdit: () {},
          ),
        ),
      );

      expect(find.byType(NotePreviewScreen), findsOneWidget);

      await tester.pumpWidget(Container());
      await tester.pumpAndSettle();
    });

    testWidgets('loads note content after relay response', (tester) async {
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

      relayChannel.onAdd = (data, channel) {
        if (data is String && data.startsWith('["REQ"')) {
          Future.microtask(() {
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
          child: NotePreviewScreen(
            pathParams: const PathParams(id: _TestEvents.noteDTag),
            coordinator: const _FakeNotePreviewCoordinator(),
            onEdit: () {},
          ),
        ),
      );

      expect(find.byType(NotePreviewScreen), findsOneWidget);

      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 500));

      // Note is loaded: content area is visible (not CannotDecryptPlaceholder)
      expect(find.byType(SingleChildScrollView), findsOneWidget);

      final db = di.resolve<AppDatabase>();
      await db.close();
      await tester.pump();

      await tester.pumpWidget(Container());
      await tester.pumpAndSettle();
    });

    testWidgets('shows search bar after tapping search button', (tester) async {
      final di = DiStorage.shared;

      final SessionUsecase session = DiStorage.shared.resolve();
      session.setSession(const Unlocked(keys: _Helper.keys, pin: _Helper.pin));

      when(
        () => mockUuid.v4(),
      ).thenReturn('f5996f40-6622-11f0-b6aa-77622cb064581');
      when(
        () => channelFactory.create('wss://test.relay'),
      ).thenReturn(relayChannel);

      relayChannel.onAdd = (data, channel) {
        if (data is String && data.startsWith('["REQ"')) {
          Future.microtask(() {
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
          child: NotePreviewScreen(
            pathParams: const PathParams(id: _TestEvents.noteDTag),
            coordinator: const _FakeNotePreviewCoordinator(),
            onEdit: () {},
          ),
        ),
      );

      await tester.pump(const Duration(seconds: 3));

      // Search TextField not yet visible
      expect(find.byType(TextField), findsNothing);

      // Tap search icon
      await tester.tap(find.byIcon(Icons.search_rounded));
      await tester.pumpAndSettle();

      // Search TextField is now visible
      expect(find.byType(TextField), findsOneWidget);

      // Tap again to close
      await tester.tap(find.byIcon(Icons.search_off_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNothing);

      final db = di.resolve<AppDatabase>();
      await db.close();
      await tester.pump();

      await tester.pumpWidget(Container());
      await tester.pumpAndSettle();
    });
  });
}

/// Reuses note events from notes_list_test for the same key pair.
final class _TestEvents {
  /// dTag of note1
  static const noteDTag = '73d5e300-2529-11f1-a529-611a9024e8ba';

  static const note1 = r'''["EVENT", "f5996f40-6622-11f0-b6aa-77622cb064581",
    {
        "content": "AtfebdJN/dW8bGeY/wu716HmFK/CrmSdF2BIxgoJz+maKO8US3RWKhRM7MCwwl5smKsmWzoBqH53bBpEsqjoykE+TxeifgHJajCSVKa1DtVyiFyifXQYf+pXXG3LbQpKj85U",
        "created_at": 1774099539,
        "id": "c68352568e2dc5c19c3709be52a5c4b745fe960dc98c9431ed677a0201ffd63c",
        "kind": 30023,
        "pubkey": "bfea1ad2fdbbdd4c6d2419b3d4f63f09ad8a94d5835a7f97453eb93e860ea8fe",
        "sig": "557e3fd2c932d2b5c5b208687af83c3806d873940462edcd21acee3c4f158a29044340e4bd730fb035d87b95b9e2a6049ed537e47bffc348286d73c294713159",
        "tags": [
            ["client", "996e10ba"],
            ["t", "996e10ba"],
            ["d", "73d5e300-2529-11f1-a529-611a9024e8ba"],
            ["p", "bfea1ad2fdbbdd4c6d2419b3d4f63f09ad8a94d5835a7f97453eb93e860ea8fe"],
            ["summary", "ArxSP2z6YfrygW7GSPHSJfvY+YYtRLgyps+x3W4F+rsry/TvCrfWwD78U7G7Tz8WpOxHw23RTyi536CRmezctA28xhrmCEKEFjDjX6TAQXdV2zMMUXH4fOIaCcR6VGB7qS8Z"]
        ]
    }
]''';
}

final class _Helper {
  static const iPhoneSize = Size(1170, 2532);
  static const devicePixelRatio = 3.0;

  static const keys = UserKeys(
    publicKey:
        'bfea1ad2fdbbdd4c6d2419b3d4f63f09ad8a94d5835a7f97453eb93e860ea8fe',
    privateKey:
        'efb23a073532e28f8f3cf1b3ba4bc92f1bb6ab4dd365c853cabf9b70044e3240',
  );
  static const pin = '1234';
}
