import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nostr_notes/app/router/app_router.dart';
import 'package:nostr_notes/app/router/app_router_path.dart';
import 'package:nostr_notes/auth/presentation/home_screen/left_drawer.dart';

const _detailPath = 'detail';

void main() {
  late GoRouter router;
  late BuildContext homeContext;

  final coordinator = HomeScreenCoordinatorImpl(
    homeScaffoldKey: GlobalKey<ScaffoldState>(),
    leftDrawerKey: GlobalKey<LeftDrawerState>(),
  );

  Future<void> pumpRouter(WidgetTester tester) async {
    router = GoRouter(
      initialLocation: AppRouterPath.home,
      routes: [
        ShellRoute(
          builder: (context, state, child) => Builder(
            builder: (context) {
              homeContext = context;
              return child;
            },
          ),
          routes: [
            GoRoute(
              path: AppRouterPath.home,
              builder: (_, _) => const Text('placeholder'),
              routes: [
                GoRoute(
                  path: _detailPath,
                  builder: (_, _) => const Text('detail'),
                ),
              ],
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  }

  testWidgets('switching tabs closes the detail opened from the other tab', (
    tester,
  ) async {
    await pumpRouter(tester);
    router.push('${AppRouterPath.home}/$_detailPath');
    await tester.pumpAndSettle();
    expect(find.text('detail'), findsOneWidget);

    coordinator.onTabChanged(homeContext);
    await tester.pumpAndSettle();

    expect(find.text('placeholder'), findsOneWidget);
    expect(find.text('detail'), findsNothing);
  });

  testWidgets('switching tabs with nothing open keeps the placeholder', (
    tester,
  ) async {
    await pumpRouter(tester);

    coordinator.onTabChanged(homeContext);
    await tester.pumpAndSettle();

    expect(find.text('placeholder'), findsOneWidget);
    expect(router.state.fullPath, AppRouterPath.home);
  });
}
