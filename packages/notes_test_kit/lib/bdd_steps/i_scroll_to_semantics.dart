import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:notes_test_kit/pump_helpers.dart';

const _scrollStep = 100.0;

/// Text fields scroll horizontally on their own; the page is the vertical one.
final _verticalScrollable = find.byWidgetPredicate(
  (widget) =>
      widget is Scrollable &&
      axisDirectionToAxis(widget.axisDirection) == Axis.vertical,
);

/// Usage: I scroll to {'credentials_data.pin.copy'} semantics
///
/// A lazy list builds an off-screen item only once it is scrolled near, so
/// [WidgetTester.ensureVisible] alone cannot reach it.
Future<void> iScrollToSemantics(WidgetTester tester, String identifier) async {
  final finder = PumpHelpers.findBySemanticsId(identifier);
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      _scrollStep,
      scrollable: _verticalScrollable.first,
    );
  }
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
}
