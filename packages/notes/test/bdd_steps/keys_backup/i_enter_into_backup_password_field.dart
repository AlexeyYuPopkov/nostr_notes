import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Usage: I enter {'1234'} into backup password field
Future<void> iEnterIntoBackupPasswordField(
  WidgetTester tester,
  String password,
) async {
  final passwordField = find.byWidgetPredicate(
    (widget) => widget is TextField && widget.obscureText,
  );
  await tester.enterText(passwordField.first, password);
  await tester.pumpAndSettle();
}
