import 'package:di_storage/di_storage.dart';

import 'unauth/unauth_di_scope.dart';

final class AppDi {
  const AppDi();

  static void bindUnauthModules() {
    final di = DiStorage.shared;

    di.removeScope<UnauthDiScope>();

    const UnauthDiScope().bind(di);
  }
}
