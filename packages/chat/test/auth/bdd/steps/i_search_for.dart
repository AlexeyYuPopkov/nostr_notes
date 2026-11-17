import 'package:app_test_kit/pump_helpers.dart';
import 'package:chat/auth/chat/presentation/search_contact/provider/search_contact_provider.dart';
import 'package:chat/auth/chat/presentation/search_contact/search_contact_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Usage: And I search for {'ali'}
///
/// Waits out the search debounce, as a user pausing after typing would.
Future<void> iSearchFor(WidgetTester tester, String query) async {
  final field = find.descendant(
    of: PumpHelpers.findBySemanticsId(
      SearchContactScreen.searchFieldSemanticsId,
    ),
    matching: find.byType(TextField),
  );
  await tester.enterText(field, query);
  await tester.pump(SearchContactProvider.debounceDuration);
  await PumpHelpers.pumpUntilIdle(tester);
}
