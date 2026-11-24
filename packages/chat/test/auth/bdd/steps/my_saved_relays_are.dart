import 'package:common/domain/repo/relays_list_repo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

/// Usage: Then my saved relays are {'wss://a.example, wss://b.example'}
///
/// Comma-separated; `''` means none.
Future<void> mySavedRelaysAre(WidgetTester tester, String relays) async {
  final expected = relays
      .split(',')
      .map((relay) => relay.trim())
      .where((relay) => relay.isNotEmpty)
      .toSet();
  expect(GetIt.I.get<RelaysListRepo>().getRelaysList(), expected);
}
