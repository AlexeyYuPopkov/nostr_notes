import 'dart:async';
import 'package:di_storage/di_storage.dart';
import 'package:nostr_notes/app/di/auth/auth_di_scope.dart';
import 'package:nostr_notes/app/di/unauth/db_module.dart';
import 'package:nostr_notes/services/nostr_client/outbox_publisher.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'unauth/unauth_di_scope.dart';

abstract interface class Di {
  static Di? _instance;
  static void overrideDi(Di di) => _instance = di;
  static Di get instance => _instance ??= const AppDi();

  Future<void> bindUnauthModules();
  Future<void> bindAuthModules();

  void removeUnauthModules();
  void removeAuthModules();
}

final class AppDi implements Di {
  const AppDi();

  @override
  Future<void> bindUnauthModules() async {
    final di = DiStorage.shared;

    di.removeScope<UnauthDiScope>();
    di.removeScope<DbModule>();
    di.removeScope<CryptoDiModule>();

    final prefs = await SharedPreferences.getInstance();

    UnauthDiScope(prefs: prefs).bind(di);
    const DbModule().bind(di);

    await const CryptoDiModule().bind(di);
  }

  @override
  Future<void> bindAuthModules() async {
    final di = DiStorage.shared;

    di.removeScope<AuthDiScope>();

    const AuthDiScope().bind(di);
    final outbox = di.tryResolve<OutboxPublisher>();
    await outbox?.init();
  }

  @override
  void removeAuthModules() {
    final di = DiStorage.shared;
    di.removeScope<AuthDiScope>();
  }

  @override
  void removeUnauthModules() {
    final di = DiStorage.shared;
    di.removeScope<UnauthDiScope>();
    di.removeScope<DbModule>();
    di.removeScope<CryptoDiModule>();
  }
}
