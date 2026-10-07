import 'package:di_storage/di_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../integration_test/di/test_app_di_overrides_proxy.dart';

/// Usage: a fresh install
Future<void> aFreshInstall(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  FlutterSecureStorage.setMockInitialValues({});
  // Binding opens the database, which completes only on the real clock,
  // not inside testWidgets' FakeAsync zone.
  await tester.runAsync(const TestAppDiOverridesProxy().bindUnauthModules);
  addTearDown(DiStorage.shared.removeAll);
}
