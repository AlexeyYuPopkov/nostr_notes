import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nostr_notes/app/di/app_di.dart';
import 'package:nostr_notes/app/l10n/localization.dart';
import 'package:nostr_notes/app/theme/app_theme.dart';
import 'package:nostr_notes/app/router/app_router.dart';
import 'package:nostr_notes/common/data/root_context_provider/root_context_provider.dart';

final _appRouter = AppRouter();

void main() {
  AppDi.bindUnauthModules();
  HttpOverrides.global = MyHttpOverrides();
  runApp(const App());
}

final class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Nostr Notes',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      localizationsDelegates: Localization.localizationsDelegates,
      supportedLocales: Localization.supportedLocales,
      routerConfig: _appRouter.router,
      builder: (context, child) {
        RootContextProvider.instance.setRootContext(context);
        return child!;
      },
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        return true;
      };
  }
}
