import 'package:common/presentation/raw_event/raw_event_screen.dart';
import 'package:common/services/event_store/database/app_database.dart';
import 'package:common/services/event_store/raw_event_store.dart';
import 'package:di_storage/di_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nostr/model/nostr_event.dart';
import 'package:nostr/nostr_client/channel_factory.dart';
import 'package:nostr/nostr_client/nostr_client.dart';
import 'package:uuid/uuid.dart';

import '../../tools/app_launcher/app_launcher.dart';
import '../../tools/di/in_memory_db_module.dart';
import '../../tools/moks.dart';

class MockChannelFactory extends Mock implements ChannelFactory {}

class MockUuid extends Mock implements Uuid {}

void main() {
  late NostrClient client;
  late MockChannelFactory channelFactory;
  late MockWSChannel channel;
  late MockWSChannel channel2;
  late Uuid mockUuid;

  setUp(() {
    final di = DiStorage.shared;
    di.removeAll();

    const InMemoryDbModule().bind(di);

    channelFactory = MockChannelFactory();
    mockUuid = MockUuid();
    channel = MockWSChannel(url: 'ws://test.relay');
    channel2 = MockWSChannel(url: 'ws://test2.relay');
    when(() => channelFactory.create('ws://test.relay')).thenReturn(channel);
    when(() => channelFactory.create('ws://test2.relay')).thenReturn(channel2);
    client = NostrClient(channelFactory: channelFactory, uuid: mockUuid);

    di.bind<NostrClient>(
      () => client,
      module: null,
      lifeTime: const LifeTime.single(),
    );
  });

  tearDown(() async {
    final db = DiStorage.shared.resolve<AppDatabase>();
    await db.close();
    DiStorage.shared.removeAll();
  });

  group('RawEventScreen', () {
    testWidgets('check flow', (tester) async {
      const testEventId =
          'a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2';
      const testEvent = NostrEvent(
        id: testEventId,
        kind: 1,
        pubkey:
            'deadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef',
        createdAt: 1700000000,
        tags: [],
        content: 'hello world',
        sig: '',
      );

      final rawEventStore = DiStorage.shared.resolve<RawEventStore>();
      await rawEventStore.upsert([testEvent]);

      when(() => channelFactory.create('ws://test.relay')).thenReturn(channel);
      when(() => mockUuid.v4()).thenReturn('test-uuid');

      await tester.pumpWidget(
        AppLauncher.launchApp(
          child: const RawEventScreen(eventId: testEventId),
          tester: tester,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(RawEventScreen), findsOneWidget);
      expect(find.text('Raw event'), findsOneWidget);
      expect(find.text('Relays (0)'), findsOneWidget);
      expect(find.text('JSON'), findsOneWidget);
    });

    testWidgets('shows relays when event is stored from 2 relays', (
      tester,
    ) async {
      const testEventId =
          'b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3';
      const relay1Url = 'ws://test.relay';
      const relay2Url = 'ws://test2.relay';

      const eventJson =
          '{"id":"$testEventId","kind":1,"pubkey":"deadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef","created_at":1700000000,"tags":[],"content":"hello world","sig":""}';

      channel.onAdd = (data, ch) {
        ch.mockStream.add('["EVENT","test-uuid",$eventJson]');
      };
      channel2.onAdd = (data, ch) {
        ch.mockStream.add('["EVENT","test-uuid",$eventJson]');
      };

      client.addRelays([relay1Url, relay2Url]);

      when(() => mockUuid.v4()).thenReturn('test-uuid');

      await tester.pumpWidget(
        AppLauncher.launchApp(
          child: const RawEventScreen(eventId: testEventId),
          tester: tester,
        ),
      );

      // Allow microtask (sendRequestToAll) + 100ms bufferTime + 1s debounce (AppDurations.extraLong)
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(find.byType(RawEventScreen), findsOneWidget);
      expect(find.text('Raw event'), findsOneWidget);
      expect(find.text('Relays (2)'), findsOneWidget);
      expect(find.text(relay1Url), findsOneWidget);
      expect(find.text(relay2Url), findsOneWidget);
      expect(find.text('JSON'), findsOneWidget);
    });
  });
}
