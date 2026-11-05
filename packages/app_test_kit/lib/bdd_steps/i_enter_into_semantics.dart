import 'package:app_test_kit/pump_helpers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Usage: When I enter {'Bob'} into semantics {'ProfileScreen.nameField'}
Future<void> iEnterIntoSemantics(
  WidgetTester tester,
  String text,
  String identifier,
) async {
  final field = find.descendant(
    of: PumpHelpers.findBySemanticsId(identifier),
    matching: find.byType(EditableText),
  );
  await tester.enterText(field, text);
  await tester.pump();
}
