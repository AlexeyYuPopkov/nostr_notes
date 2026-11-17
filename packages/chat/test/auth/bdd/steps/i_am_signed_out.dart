import 'package:chat/common/domain/models/session.dart';
import 'package:chat/common/domain/usecase/auth_usecase.dart';
import 'package:chat/common/domain/usecase/session_usecase.dart';
import 'package:common/domain/repo/secure_storage.dart';
import 'package:common/services/event_store/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

/// Usage: And I am signed out
///
/// The session is over, the private key is gone from the device and the
/// auth scope (database, relay client, outbox) is released.
Future<void> iAmSignedOut(WidgetTester tester) async {
  expect(GetIt.I.get<SessionUsecase>().currentSession, isA<Unauth>());
  final storedKey = await GetIt.I.get<SecureStorage>().getValue(
    key: AuthUsecase.secureStorageKey,
  );
  expect(storedKey, isEmpty);
  expect(GetIt.I.isRegistered<AppDatabase>(), isFalse);
}
