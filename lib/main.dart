import 'package:flutter/material.dart';
import 'package:nostr_notes/router/app_router.dart';

final _appRouter = AppRouter();

void main() => runApp(const App());

final class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Nostr Notes',
      routerConfig: _appRouter.router,
    );
  }
}
