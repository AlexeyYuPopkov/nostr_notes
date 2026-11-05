import 'package:app_test_kit/pump_helpers.dart';
import 'package:flutter_test/flutter_test.dart';

/// Usage (in an `After:` block): I close the app
///
/// Unmounts the tree while fake time still runs, then lets it run a little
/// longer, so timers left by disposal fire inside the test: drift closing a
/// watched query, or flutter_chat_ui 2.11's scroll-to-end delay, which its
/// list does not cancel on dispose.
Future<void> iCloseTheApp(WidgetTester tester) async {
  await PumpHelpers.unmount(tester);
  await tester.pump(_lingeringTimers);
}

const _lingeringTimers = Duration(seconds: 1);
