import 'package:app_test_kit/pump_helpers.dart';
import 'package:chat/auth/home/presentation/home/home_navigation_bar.dart';
import 'package:chat/auth/settings/presentation/settings/items/settings_item.dart';
import 'package:flutter_test/flutter_test.dart';

import 'i_open_the_authorized_area.dart';

/// Usage: When I open the relays list
///
/// Goes the user's way: the settings tab, then its relays item.
Future<void> iOpenTheRelaysList(WidgetTester tester) async {
  await iOpenTheAuthorizedArea(tester);
  await tester.tap(
    PumpHelpers.findBySemanticsId(HomeNavigationBar.settingsTabSemanticsId),
  );
  await PumpHelpers.pumpUntilIdle(tester);
  await tester.tap(
    PumpHelpers.findBySemanticsId(const SettingsItemRelays().semanticsId),
  );
  await PumpHelpers.pumpUntilIdle(tester);
}
