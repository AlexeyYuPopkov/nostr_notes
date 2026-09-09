import 'dart:async';

import 'package:common/domain/usecases/relays_monitoring_usecase.dart';
import 'package:di_storage/di_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr/model/relay_health.dart';
import 'package:nostr_notes/auth/presentation/dashboard/widgets/relay_status_indicator.dart';

import '../../../../tools/app_launcher/app_launcher.dart';
import '../../../../tools/app_launcher/pump_helpers.dart';

/// Hand-rolled fake instead of a mocktail mock: RelaysMonitoringUsecase is
/// a one-getter interface, so a plain StreamController is simpler than
/// stubbing `when(() => usecase.statuses).thenAnswer(...)`.
final class _FakeRelaysMonitoringUsecase implements RelaysMonitoringUsecase {
  final _controller = StreamController<Map<String, RelayStatus>>.broadcast();

  @override
  Stream<Map<String, RelayStatus>> get statuses => _controller.stream;

  void emit(Map<String, RelayStatus> statuses) => _controller.add(statuses);

  @override
  Future<void> dispose() async => _controller.close();
}

/// A single fixed frame isn't guaranteed to observe a value freshly pushed
/// through RelayStatusIndicatorVM's mapped stream (RelaysMonitoringUsecase
/// -> .map() -> StreamBuilder) — see PumpHelpers.waitFor's doc: this polls
/// frames until the predicate holds instead of assuming one pump suffices.
Finder _progressWithValue(double? value) => find.byWidgetPredicate(
  (w) => w is CircularProgressIndicator && w.value == value,
);

void main() {
  const relay1 = 'wss://relay1.example.com';
  const relay2 = 'wss://relay2.example.com';
  const relay3 = 'wss://relay3.example.com';

  late _FakeRelaysMonitoringUsecase usecase;

  setUp(() {
    usecase = _FakeRelaysMonitoringUsecase();
    DiStorage.shared.bind<RelaysMonitoringUsecase>(
      () => usecase,
      module: null,
      lifeTime: const LifeTime.single(),
    );
  });

  tearDown(() async {
    DiStorage.shared.removeAll();
    await usecase.dispose();
  });

  Future<void> pumpIndicator(WidgetTester tester) async {
    await tester.pumpWidget(
      AppLauncher.launchApp(
        tester: tester,
        child: const Scaffold(body: Center(child: RelayStatusIndicator())),
      ),
    );
  }

  testWidgets('renders nothing before any statuses are known', (tester) async {
    await pumpIndicator(tester);
    await tester.pump();

    expect(find.byIcon(Icons.cell_tower), findsNothing);
  });

  testWidgets('renders nothing if statuses arrive but the map is empty', (
    tester,
  ) async {
    await pumpIndicator(tester);

    usecase.emit(const {});
    await tester.pump();

    expect(find.byIcon(Icons.cell_tower), findsNothing);
  });

  testWidgets('shows the connectivity icon once statuses arrive', (
    tester,
  ) async {
    await pumpIndicator(tester);

    usecase.emit({relay1: RelayStatus.connected});
    await PumpHelpers.waitFor(
      tester,
      find.byIcon(Icons.cell_tower),
      reason: 'icon should appear once a status map is emitted',
    );

    expect(find.byIcon(Icons.cell_tower), findsOneWidget);
  });

  testWidgets(
    'the ring value tracks the connected/total ratio and updates live',
    (tester) async {
      await pumpIndicator(tester);

      usecase.emit({relay1: RelayStatus.warning, relay2: RelayStatus.warning});
      await PumpHelpers.waitFor(
        tester,
        _progressWithValue(0.0),
        reason: 'no relay connected yet -> 0/2',
      );

      usecase.emit({
        relay1: RelayStatus.connected,
        relay2: RelayStatus.disconnected,
      });
      await PumpHelpers.waitFor(
        tester,
        _progressWithValue(0.5),
        reason: 'one of two relays connected -> 1/2',
      );

      usecase.emit({
        relay1: RelayStatus.connected,
        relay2: RelayStatus.connected,
      });
      await PumpHelpers.waitFor(
        tester,
        _progressWithValue(1.0),
        reason: 'both relays connected -> 2/2',
      );
    },
  );

  testWidgets('tapping opens a popover listing every relay by host', (
    tester,
  ) async {
    await pumpIndicator(tester);

    usecase.emit({
      relay1: RelayStatus.connected,
      relay2: RelayStatus.warning,
      relay3: RelayStatus.disconnected,
    });
    await PumpHelpers.waitFor(
      tester,
      find.byIcon(Icons.cell_tower),
      reason: 'icon should appear once statuses are emitted',
    );

    await tester.tap(find.byIcon(Icons.cell_tower));
    await PumpHelpers.waitFor(
      tester,
      find.text('1 of 3 relays online'),
      reason: 'popover should open on tap',
    );

    expect(find.text('relay1.example.com'), findsOneWidget);
    expect(find.text('relay2.example.com'), findsOneWidget);
    expect(find.text('relay3.example.com'), findsOneWidget);
    expect(find.text('online'), findsOneWidget);
    expect(find.text('connecting…'), findsOneWidget);
    expect(find.text('no response'), findsOneWidget);
  });

  testWidgets('popover rows are sorted by relay url', (tester) async {
    await pumpIndicator(tester);

    usecase.emit({
      relay3: RelayStatus.warning,
      relay1: RelayStatus.warning,
      relay2: RelayStatus.warning,
    });
    await PumpHelpers.waitFor(
      tester,
      find.byIcon(Icons.cell_tower),
      reason: 'icon should appear once statuses are emitted',
    );

    await tester.tap(find.byIcon(Icons.cell_tower));
    await PumpHelpers.waitFor(
      tester,
      find.text('0 of 3 relays online'),
      reason: 'popover should open on tap',
    );

    final hosts = tester
        .widgetList<Text>(find.textContaining('.example.com'))
        .map((t) => t.data)
        .toList();
    expect(hosts, [
      'relay1.example.com',
      'relay2.example.com',
      'relay3.example.com',
    ]);
  });
}
