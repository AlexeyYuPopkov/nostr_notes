import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> inputAtFirstTf(WidgetTester tester, String text) async {
  final firstTf = find.byType(TextField).first;
  await tester.enterText(firstTf, text);
}
