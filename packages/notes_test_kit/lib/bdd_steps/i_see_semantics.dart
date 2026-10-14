import 'package:flutter_test/flutter_test.dart';

import 'package:notes_test_kit/pump_helpers.dart';
import 'i_scroll_to_semantics.dart';

/// Usage: I see {'credentials_data.nsec.copy'} semantics
Future<void> iSeeSemantics(WidgetTester tester, String identifier) async {
  await iScrollToSemantics(tester, identifier);
  expect(
    PumpHelpers.findBySemanticsId(identifier).hitTestable(),
    findsOneWidget,
  );
}
