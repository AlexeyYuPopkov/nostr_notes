import 'package:flutter/material.dart';
import 'package:nostr_notes/app/router/app_route/route_handler.dart';
import 'package:nostr_notes/app/router/screens_assembly/screens_assembly.dart';
import 'package:nostr_notes/auth/presentation/settings/preferences/credentials_data_screen/credentials_data_screen.dart';
import 'package:nostr_notes/auth/presentation/settings/preferences/locale/locale_settings_screen.dart';
import 'package:nostr_notes/auth/presentation/settings/preferences/mobile_keyboard_type/mobile_keyboard_type_screen.dart';
import 'package:common/presentation/theme_settings/theme_settings_screen.dart';
import 'package:nostr_notes/auth/presentation/settings/settings/settings_screen.dart';
import 'package:nostr_notes/auth/presentation/settings/settings/settings_screen_routes.dart';

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
                    builder: (context) => RouteHandlerWidget(
                      child: screensAssembly.createAppSettingsScreen(),
                      onRoute: (route, context) {
                        if (route is RelaysListRoute) {
                          return Navigator.of(context).push(
                            MaterialPageRoute(
                              settings: const RouteSettings(
                                name: 'relays_list',
                              ),
                              builder: (context) =>
                                  screensAssembly.createRelaysListScreen(),
                            ),
                          );
                        } else if (route is PinKeyboardTypeRoute) {
                          return Navigator.of(context).push(
                            MaterialPageRoute(
                              settings: const RouteSettings(
                                name: 'pin_keyboard_type',
                              ),
                              builder: (context) =>
                                  const MobileKeyboardTypeScreen(),
                            ),
                          );
                        } else if (route is LocaleSettingsRoute) {
                          return Navigator.of(context).push(
                            MaterialPageRoute(
                              settings: const RouteSettings(
                                name: 'locale_settings',
                              ),
                              builder: (context) =>
                                  const LocaleSettingsScreen(),
                            ),
                          );
                        } else if (route is CredentialsDataRoute) {
                          return Navigator.of(context).push(
                            MaterialPageRoute(
                              settings: const RouteSettings(
                                name: 'pin_keyboard_type',
                              ),
                              builder: (context) =>
                                  const CredentialsDataScreen(),
                            ),
                          );
                        } else if (route is ThemeSettingsRoute) {
                          return Navigator.of(context).push(
                            MaterialPageRoute(
                              settings: const RouteSettings(
                                name: 'theme_settings',
                              ),
                              builder: (context) => const ThemeSettingsScreen(),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                );
              } else if (route is HelpScreenRoute) {
                return Navigator.of(context).push(
                  MaterialPageRoute(
                    settings: const RouteSettings(name: 'help_screen'),
                    builder: (context) => screensAssembly.createHelpScreen(),
                  ),
                );
              } else if (route is ContactsScreenRoute) {
                return Navigator.of(context).push(
                  MaterialPageRoute(
                    settings: const RouteSettings(name: 'contacts_screen'),
                    builder: (context) =>
                        screensAssembly.createContactsScreen(showAppBar: true),
                  ),
                );
              } else if (route is DeleteAccRoute) {
                return Navigator.of(context).push(
                  MaterialPageRoute(
                    settings: const RouteSettings(name: 'delete_acc_screen'),
                    builder: (context) =>
                        screensAssembly.deleteAccUsecaseScreen(),
                  ),
                );
              } else if (route is DonateLightningRoute) {
                return Navigator.of(context).push(
                  MaterialPageRoute(
                    settings: const RouteSettings(name: 'donate_lightning'),
                    builder: (context) =>
                        screensAssembly.createDonateLightningScreen(),
                  ),
                );
              } else if (route is ExportImportRoute) {
                return Navigator.of(context).push(
                  MaterialPageRoute(
                    settings: const RouteSettings(name: 'export_import_screen'),
                    builder: (context) => RouteHandlerWidget(
                      child: screensAssembly.createExportImportScreen(),
                      onRoute: (route, context) {
                        if (route is CloseSettingsRoute) {
                          Navigator.of(context).popUntil((r) => r.isFirst);
                          Scaffold.maybeOf(context)?.closeEndDrawer();
                          return null;
                        }
                        return RouteHandler.of(
                          context,
                        )?.onRoute(route, context);
                      },
                    ),
                  ),
                );
              } else if (route is CloseSettingsRoute) {
                Navigator.of(context).popUntil((r) => r.isFirst);
                Scaffold.maybeOf(context)?.closeEndDrawer();
                return null;
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
