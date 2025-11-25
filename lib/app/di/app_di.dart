import 'dart:async';
import 'package:di_storage/di_storage.dart';
import 'package:nostr_notes/app/di/auth/auth_di_scope.dart';

import 'unauth/unauth_di_scope.dart';

final class AppDi {
  const AppDi();

  static FutureOr<void> bindUnauthModules() async {
    final di = DiStorage.shared;

    di.removeScope<UnauthDiScope>();
    di.removeScope<CryptoDiModule>();

    const UnauthDiScope().bind(di);

    await const CryptoDiModule().bind(di);

    // await di.resolve<AesCbcRepo>().init();
  }

  static void bindAuthModules() {
    final di = DiStorage.shared;

    di.removeScope<AuthDiScope>();

    const AuthDiScope().bind(di);
  }
}
