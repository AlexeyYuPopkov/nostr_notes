import 'package:chat/common/di/di.dart';
import 'package:chat/l10n/localization.dart';
import 'package:common/app/vm/global_settings_scope.dart';
import 'package:common/app/vm/global_settings_vm.dart';
import 'package:common/domain/repo/secure_storage.dart';
import 'package:common/l10n/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:common/app/theme/app_theme.dart';
import 'package:common/presentation/tools/root_context_provider/root_context_provider.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class _FakeSecureStorage implements SecureStorage {
  final _store = <String, String>{};

  @override
  Future<String> getValue({required String key}) async => _store[key] ?? '';

  @override
  Future<void> setValue({required String key, required String value}) async {
    _store[key] = value;
  }

  @override
  Future<void> deleteValue({required String key}) async {
    _store.remove(key);
  }
}

final _globalSettingsVm = GlobalSettingsVm();

final class AppLauncher {
  static Future<void> setUp() async {
    SharedPreferences.setMockInitialValues({});
    await Di.registerUnauthModules();
    GetIt.I.unregister<SecureStorage>();
    GetIt.I.registerSingleton<SecureStorage>(_FakeSecureStorage());
  }

  static Future<void> tearDown() async {
    await Di.dropUnauthModules();
  }

  static Widget launchApp({
    required Widget child,
    required WidgetTester tester,
    GlobalSettingsVm? globalSettingsVm,
  }) {
    final globSettingsVm = globalSettingsVm ?? _globalSettingsVm;
    return ProviderScope(
      child: GlobalSettingsScope(
        vm: globSettingsVm,
        child: ValueListenableBuilder(
          valueListenable: globSettingsVm.themeModeNotifier,
          builder: (context, themeMode, _) => MaterialApp(
            // onGenerateTitle: (context) => context.l10n.appDisplayName,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeMode,
            localizationsDelegates: const [
              ...Localization.localizationsDelegates,
              ...CommonL10n.localizationsDelegates,
            ],
            supportedLocales: CommonL10n.supportedLocales,
            debugShowCheckedModeBanner: false,
            // home: child,
            builder: (context, _) {
              RootContextProvider.instance.setRootContext(context);
              return child;
            },
          ),
        ),
      ),
    );
  }
}
