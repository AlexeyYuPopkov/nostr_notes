import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'fake_profile_usecases.dart';

/// Usage: And no relay accepts my profile
Future<void> noRelayAcceptsMyProfile(WidgetTester tester) async {
  GetIt.I.get<FakeProfileStore>().relaysAccept = false;
}
