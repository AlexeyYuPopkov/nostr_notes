import 'package:common/data/repo/app_shared_prefs_impl.dart';
import 'package:common/data/repo/app_theme_data_repo_impl.dart';
import 'package:common/domain/repo/app_shared_prefs.dart';
import 'package:common/presentation/theme_settings/global_settings_vm.dart';
import 'package:common/app/vm/global_settings_scope.dart';
import 'package:common/l10n/localization.dart';
import 'package:di_storage/di_storage.dart';
import 'package:flutter/material.dart';
import 'package:nostr_notes/app/di/app_di.dart';
import 'package:nostr_notes/common/presentation/blur_widget/verification_widget.dart';
import 'package:nostr_notes/l10n/localization.dart';
import 'package:common/app/theme/app_theme.dart';
import 'package:nostr_notes/app/router/app_router.dart';
import 'package:common/presentation/tools/root_context_provider/root_context_provider.dart';
import 'package:nostr_notes/services/outbox_publisher.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter/scheduler.dart';

final _appRouter = AppRouter();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setUrlStrategy(const HashUrlStrategy());

  await Di.instance.bindUnauthModules();
  // HttpOverrides.global = MyHttpOverrides();
  // timeDilation = 4.0;
  final prefs = AppSharedPrefsImpl(await SharedPreferences.getInstance());
  runApp(App(prefs: prefs));
}

final class App extends StatefulWidget {
  final AppSharedPrefs prefs;

  const App({super.key, required this.prefs});

  @override
  State<App> createState() => _AppState();
}

final class _AppState extends State<App> with WidgetsBindingObserver {
  late final _globalSettingsVm = GlobalSettingsVm(
    appThemeDataRepo: AppThemeDataRepoImpl(widget.prefs),
  );

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
      case AppLifecycleState.detached:
        DiStorage.shared.tryResolve<OutboxPublisher>()?.resume();
        // _blurScreenUsecase.onForeground();
        break;

      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        DiStorage.shared.tryResolve<OutboxPublisher>()?.pause();
        // _blurScreenUsecase.onBackground();
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlobalSettingsScope(
      vm: _globalSettingsVm,
      child: ListenableBuilder(
        listenable: Listenable.merge([
          _globalSettingsVm.themeModeNotifier,
          _globalSettingsVm.localeNotifier,
          _globalSettingsVm.lightThemeStyleNotifier,
          _globalSettingsVm.darkThemeStyleNotifier,
        ]),
        builder: (context, _) {
          final vm = _globalSettingsVm;
          return MaterialApp.router(
            onGenerateTitle: (context) => context.l10n.appDisplayName,
            theme: AppTheme.light(style: vm.lightThemeStyle),
            darkTheme: AppTheme.dark(style: vm.darkThemeStyle),
            themeMode: vm.themeMode,
            locale: vm.locale,
            localizationsDelegates: const [
              ...CommonL10n.localizationsDelegates,
              ...Localization.localizationsDelegates,
            ],
            supportedLocales: Localization.supportedLocales,
            localeListResolutionCallback: (locales, supportedLocales) {
              for (final locale in locales ?? const <Locale>[]) {
                for (final supported in supportedLocales) {
                  if (supported.languageCode == locale.languageCode) {
                    return supported;
                  }
                }
              }
              return const Locale('en');
            },
            routerConfig: _appRouter.router,
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              RootContextProvider.instance.setRootContext(context);
              return VerificationWidget(
                child: child ?? const SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }
}

// class MyHttpOverrides extends HttpOverrides {
//   @override
//   HttpClient createHttpClient(SecurityContext? context) {
//     return super.createHttpClient(context)
//       ..badCertificateCallback = (X509Certificate cert, String host, int port) {
//         return true;
//       };
//   }
// }
