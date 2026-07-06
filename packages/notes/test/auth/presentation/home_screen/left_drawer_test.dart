import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_notes/auth/presentation/home_screen/left_drawer.dart';

import '../../../tools/app_launcher/app_launcher.dart';

void main() {
  const drawerWidth = 300.0;
  late GlobalKey<LeftDrawerState> key;
  var tapCount = 0;

  setUp(() {
    key = GlobalKey<LeftDrawerState>();
    tapCount = 0;
  });

  Future<void> pumpLeftDrawer(WidgetTester tester) async {
    await tester.pumpWidget(
      AppLauncher.launchApp(
        tester: tester,
        child: LeftDrawer(
          key: key,
          drawerWidth: drawerWidth,
          drawer: const Text('DRAWER'),
          content: GestureDetector(
            onTap: () => tapCount++,
            child: const Text('CONTENT'),
          ),
        ),
      ),
    );
  }

  testWidgets('renders both drawer and content', (tester) async {
    await pumpLeftDrawer(tester);

    expect(find.text('DRAWER'), findsOneWidget);
    expect(find.text('CONTENT'), findsOneWidget);
  });

  testWidgets('drawer is hidden off-screen to the left initially', (
    tester,
  ) async {
    await pumpLeftDrawer(tester);

    final contentX = tester.getTopLeft(find.text('CONTENT')).dx;
    final drawerX = tester.getTopLeft(find.text('DRAWER')).dx;

    expect(contentX, 0.0);
    expect(drawerX, -drawerWidth);
  });

  testWidgets('open() slides drawer in and pushes content right', (
    tester,
  ) async {
    await pumpLeftDrawer(tester);

    key.currentState!.open();
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(find.text('DRAWER')).dx, 0.0);
    expect(tester.getTopLeft(find.text('CONTENT')).dx, drawerWidth);
  });

  testWidgets('close() slides drawer back out and restores content', (
    tester,
  ) async {
    await pumpLeftDrawer(tester);

    key.currentState!.open();
    await tester.pumpAndSettle();
    key.currentState!.close();
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(find.text('DRAWER')).dx, -drawerWidth);
    expect(tester.getTopLeft(find.text('CONTENT')).dx, 0.0);
  });

  testWidgets('content is not tappable while the drawer is open', (
    tester,
  ) async {
    await pumpLeftDrawer(tester);

    await tester.tap(find.text('CONTENT'));
    expect(tapCount, 1);

    key.currentState!.open();
    await tester.pumpAndSettle();

    await tester.tap(find.text('CONTENT'), warnIfMissed: false);
    expect(tapCount, 1);
  });

  testWidgets('tapping the scrim closes the drawer', (tester) async {
    await pumpLeftDrawer(tester);

    key.currentState!.open();
    await tester.pumpAndSettle();

    await tester.tapAt(const Offset(700, 300));
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(find.text('DRAWER')).dx, -drawerWidth);
  });
}
