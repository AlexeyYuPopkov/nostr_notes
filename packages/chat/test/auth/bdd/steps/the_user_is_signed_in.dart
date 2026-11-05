import 'package:chat/common/di/di.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../tools/app_launcher/app_launcher.dart';
import 'chat_test_world.dart';

/// Usage: Given the user is signed in
///
/// With fresh keys, an empty device and a single test relay.
Future<void> theUserIsSignedIn(WidgetTester tester) async {
  await AppLauncher.setUp();
  Di.registerAuthModules();
  await ChatTestWorld.install();
  addTearDown(() async {
    ChatTestWorld.uninstall();
    await Di.dropAuthModules();
    await AppLauncher.tearDown();
  });
}
