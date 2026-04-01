import 'package:di_storage/di_storage.dart';
import 'package:nostr_notes/app/di/app_di.dart';
import 'package:nostr_notes/app/di/unauth/db_module.dart';

import '../../test/tools/di/in_memory_db_module.dart';

final class TestAppDiOverridesProxy implements Di {
  const TestAppDiOverridesProxy();

  @override
  Future<void> bindAuthModules() async {
    await const AppDi().bindAuthModules();
  }

  @override
  Future<void> bindUnauthModules() async {
    await const AppDi().bindUnauthModules();
    final di = DiStorage.shared;
    di.removeScope<DbModule>();
    const InMemoryDbModule().bind(di);
  }

  @override
  void removeAuthModules() {
    return const AppDi().removeAuthModules();
  }

  @override
  void removeUnauthModules() {
    return const AppDi().removeUnauthModules();
  }
}
