import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Usage: I enter {'1234'} into backup password field
///
/// Scoped to the dialog: the screen behind it may have obscured fields of
/// its own (e.g. the nsec on the credentials screen).
Future<void> iEnterIntoBackupPasswordField(
  WidgetTester tester,
  String password,
) async {
  final passwordField = find.descendant(
    of: find.byType(AlertDialog),
    matching: find.byWidgetPredicate(
      (widget) => widget is TextField && widget.obscureText,
    ),
  );
  await tester.enterText(passwordField, password);
  await tester.pumpAndSettle();
}
