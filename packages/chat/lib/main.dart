import 'package:chat/l10n/localization.dart';
import 'package:chat/router/app_router.dart';
import 'package:common/app/theme/app_theme.dart';
import 'package:common/app/vm/global_settings_scope.dart';
import 'package:common/app/vm/global_settings_vm.dart';
import 'package:common/l10n/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// import 'package:flutter_web_plugins/flutter_web_plugins.dart';

// final _appRouter = AppRouter();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // if (!kIsWeb) {
  //     setUrlStrategy(const HashUrlStrategy());
  //   }

  // await Di.instance.bindUnauthModules();
  // HttpOverrides.global = MyHttpOverrides();
  // timeDilation = 4.0;
  runApp(ProviderScope(child: const App()));
}

final class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

final class _AppState extends State<App> with WidgetsBindingObserver {
  // late final BlurScreenUsecase _blurScreenUsecase = DiStorage.shared.resolve();
  final _appRouter = AppRouter();
  late final _globalSettingsVm = GlobalSettingsVm();

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
        // DiStorage.shared.tryResolve<OutboxPublisher>()?.resume();
        // _blurScreenUsecase.onForeground();
        break;

      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        // DiStorage.shared.tryResolve<OutboxPublisher>()?.pause();
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
      child: ValueListenableBuilder(
        valueListenable: _globalSettingsVm.themeModeNotifier,
        builder: (context, themeMode, _) {
          return MaterialApp.router(
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeMode,
            // locale: , // TODO: implement locale change
            localizationsDelegates: const [
              ...CommonL10n.localizationsDelegates,
              ...Localization.localizationsDelegates,
            ],
            supportedLocales: Localization.supportedLocales,
            routerConfig: _appRouter.config(),
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
