import 'package:di_storage/di_storage.dart';
import 'package:nostr_notes/app/di/auth/auth_di_scope.dart';

import 'unauth/unauth_di_scope.dart';

final class AppDi {
  const AppDi();

  static void bindUnauthModules() {
    final di = DiStorage.shared;

    di.removeScope<UnauthDiScope>();

    const UnauthDiScope().bind(di);
  }

  static void bindAuthModules() {
    final di = DiStorage.shared;

    di.removeScope<AuthDiScope>();

    const AuthDiScope().bind(di);
  }
}
