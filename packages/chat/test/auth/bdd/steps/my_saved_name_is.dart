import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'fake_profile_usecases.dart';

/// Usage: And my saved name is {'Bob'}
Future<void> mySavedNameIs(WidgetTester tester, String name) async {
  expect(GetIt.I.get<FakeProfileStore>().savedProfile.name, name);
}
