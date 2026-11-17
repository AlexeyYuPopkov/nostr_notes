import 'package:app_test_kit/pump_helpers.dart';
import 'package:chat/router/app_router.gr.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../tools/app_launcher/app_launcher.dart';

/// Usage: When I open the authorized area
Future<void> iOpenTheAuthorizedArea(WidgetTester tester) async {
  await tester.pumpWidget(
    AppLauncher.launchRouterApp(initialRoute: const AuthTabsRoute()),
  );
  await PumpHelpers.pumpUntilIdle(tester);
}
