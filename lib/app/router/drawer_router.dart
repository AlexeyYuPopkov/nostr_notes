import 'package:flutter/material.dart';
import 'package:nostr_notes/app/router/app_route/app_route.dart';
import 'package:nostr_notes/app/router/app_route/route_handler.dart';
import 'package:nostr_notes/app/router/screens_assembly/screens_assembly.dart';
import 'package:nostr_notes/auth/presentation/settings/settings/settings_screen.dart';

final class DrawerRouter extends StatelessWidget {
  final ScreensAssembly screensAssembly;

  const DrawerRouter({super.key, required this.screensAssembly});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => RouteHandlerWidget(
            child: const SettingsScreen(),
            onRoute: (route, context) {
              if (route is PreferencesRoute) {
                return Navigator.of(context).push(
                  MaterialPageRoute(
                    settings: const RouteSettings(name: 'app_settings'),
                    builder: (context) =>
                        screensAssembly.createAppSettingsScreen(),
                  ),
                );
              }

              return RouteHandler.of(context)?.onRoute(route, context);
            },
          ),
          settings: settings,
        );
      },
    );
  }
}

final class OnEndDrawer implements AppRoute {
  const OnEndDrawer();
}
