import 'dart:async';
import 'package:di_storage/di_storage.dart';
import 'package:nostr_notes/app/di/auth/auth_di_scope.dart';
import 'package:nostr_notes/app/di/unauth/db_module.dart';
import 'package:nostr_notes/services/nostr_client/outbox_publisher.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'unauth/unauth_di_scope.dart';

final class AppDi {
  const AppDi();

  static FutureOr<void> bindUnauthModules() async {
    final di = DiStorage.shared;

    di.removeScope<UnauthDiScope>();
    di.removeScope<DbModule>();
    di.removeScope<CryptoDiModule>();

    final prefs = await SharedPreferences.getInstance();

    UnauthDiScope(prefs: prefs).bind(di);
    const DbModule().bind(di);

    await const CryptoDiModule().bind(di);

    // await di.resolve<AesCbcRepo>().init();
  }

  static Future<void> bindAuthModules() async {
    final di = DiStorage.shared;

    di.removeScope<AuthDiScope>();

    const AuthDiScope().bind(di);
    final outbox = di.tryResolve<OutboxPublisher>();
    await outbox?.init();
  }
}
