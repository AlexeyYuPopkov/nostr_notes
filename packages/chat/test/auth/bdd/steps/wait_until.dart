import 'package:flutter_test/flutter_test.dart';

/// Pumps until [found] matches, letting the real clock run in between:
/// some database work in this app does not finish on fake time alone.
Future<void> waitUntilFound(
  WidgetTester tester,
  Finder found, {
  required String reason,
  Duration timeout = const Duration(seconds: 10),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (found.evaluate().isEmpty) {
    if (DateTime.now().isAfter(deadline)) {
      fail('Timed out: $reason');
    }
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }
}
