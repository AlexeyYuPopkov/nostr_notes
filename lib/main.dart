import 'package:flutter/material.dart';
import 'package:nostr_notes/app/di/app_di.dart';
import 'package:nostr_notes/app/l10n/localization.dart';
import 'package:nostr_notes/app/theme/app_theme.dart';
import 'package:nostr_notes/router/app_router.dart';

final _appRouter = AppRouter();

void main() {
  AppDi.bindUnauthModules();
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
    );
  }
}
