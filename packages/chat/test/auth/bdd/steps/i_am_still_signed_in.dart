import 'package:chat/common/domain/usecase/session_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'chat_test_world.dart';

/// Usage: And I am still signed in
Future<void> iAmStillSignedIn(WidgetTester tester) async {
  expect(
    GetIt.I.get<SessionUsecase>().currentSession.pubkey,
    ChatTestWorld.current.me.publicKey,
  );
}
