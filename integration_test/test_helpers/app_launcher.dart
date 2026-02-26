import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_notes/app/di/app_di.dart';
import 'package:nostr_notes/app/l10n/localization.dart';
import 'package:nostr_notes/app/router/app_router.dart';
import 'package:nostr_notes/app/theme/app_theme.dart';
import 'package:nostr_notes/common/data/root_context_provider/root_context_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../di/test_app_di_overrides_proxy.dart';

final class AppLauncherRobot {
  final WidgetTester tester;
  const AppLauncherRobot({required this.tester});

  Future<void> launch() async {
    await Di.instance.bindUnauthModules();
    // HttpOverrides.global = _TestHttpOverrides();

    // Clear secure storage (Hive encryption keys, auth tokens, etc.)
    await const FlutterSecureStorage().deleteAll();

    // Clear shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Di.overrideDi(const TestAppDiOverridesProxy());

    final appRouter = AppRouter();

    await tester.pumpWidget(
      MaterialApp.router(
        title: 'Nostr Notes',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.light,
        localizationsDelegates: const [
          ...Localization.localizationsDelegates,
          FlutterQuillLocalizations.delegate,
        ],
        supportedLocales: Localization.supportedLocales,
        routerConfig: appRouter.router,
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          RootContextProvider.instance.setRootContext(context);
          return child!;
        },
      ),
    );
  }
}

// class _TestHttpOverrides extends HttpOverrides {
//   @override
//   HttpClient createHttpClient(SecurityContext? context) {
//     return super.createHttpClient(context)
//       ..badCertificateCallback = (X509Certificate cert, String host, int port) {
//         return true;
//       };
//   }
// }
