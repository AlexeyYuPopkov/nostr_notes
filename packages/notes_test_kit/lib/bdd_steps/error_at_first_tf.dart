import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> errorAtFirstTf(WidgetTester tester, String text) async {
  expect(find.byType(TextField), findsAtLeast(1));
  expect(find.text(text), findsOneWidget);
}
