import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

abstract interface class PumpHelpers {
  /// Pumps [count] frames to let animations settle.
  ///
  /// Unlike [WidgetTester.pumpAndSettle], this won't hang if background
  /// streams keep scheduling frames.
  static Future<void> pumpFrames(WidgetTester tester, {int count = 10}) async {
    for (var i = 0; i < count; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  /// Pumps frames until [finder] matches at least one widget.
  ///
  /// Throws if the widget doesn't appear within [timeout].
  static Future<void> waitFor(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 15),
    required String reason,
  }) async {
    const interval = Duration(milliseconds: 100);
    final maxAttempts = timeout.inMilliseconds ~/ interval.inMilliseconds;

    for (var i = 0; i < maxAttempts; i++) {
      await tester.pump(interval);
      if (finder.evaluate().isNotEmpty) return;
    }

    fail('Timed out: $reason');
  }

  /// Finds a [Semantics] widget whose [SemanticsProperties.identifier] matches
  /// the given [identifier].
  ///
  /// Unlike [CommonFinders.bySemanticsIdentifier], this searches the widget tree
  /// directly and does not require the semantics tree to be enabled.
  static Finder findBySemanticsId(String identifier) {
    return find.byWidgetPredicate(
      (w) => w is Semantics && w.properties.identifier == identifier,
      description: 'Semantics(identifier: "$identifier")',
    );
  }

  /// Pumps frames until [finder] matches zero widgets.
  ///
  /// Throws if the widget doesn't disappear within [timeout].
  static Future<void> waitForGone(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 30),
    required String reason,
  }) async {
    const interval = Duration(milliseconds: 100);
    final maxAttempts = timeout.inMilliseconds ~/ interval.inMilliseconds;

    for (var i = 0; i < maxAttempts; i++) {
      await tester.pump(interval);
      if (finder.evaluate().isEmpty) return;
    }

    fail('Timed out: $reason');
  }
}
