import 'package:chat/common/domain/usecase/auth_usecase.dart';
import 'package:common/domain/repo/secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'chat_test_world.dart';

/// Usage: And my key is saved on this device
Future<void> myKeyIsSavedOnThisDevice(WidgetTester tester) async {
  await GetIt.I.get<SecureStorage>().setValue(
    key: AuthUsecase.secureStorageKey,
    value: ChatTestWorld.current.me.privateKey,
  );
}
