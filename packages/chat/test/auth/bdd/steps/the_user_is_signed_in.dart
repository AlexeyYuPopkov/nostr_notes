import 'package:chat/common/di/di.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../tools/app_launcher/app_launcher.dart';

/// Usage: Given the user is signed in
Future<void> theUserIsSignedIn(WidgetTester tester) async {
  await AppLauncher.setUp();
  Di.registerAuthModules();
  addTearDown(() async {
    await Di.dropAuthModules();
    await AppLauncher.tearDown();
  });
}
