import 'package:common/app/vm/global_settings_vm.dart';
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

final _appRouter = AppRouter();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setUrlStrategy(const HashUrlStrategy());

  await Di.instance.bindUnauthModules();
  // HttpOverrides.global = MyHttpOverrides();
  // timeDilation = 4.0;
  runApp(const App());
}

final class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

final class _AppState extends State<App> with WidgetsBindingObserver {
  // late final BlurScreenUsecase _blurScreenUsecase = DiStorage.shared.resolve();

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
      child: ValueListenableBuilder(
        valueListenable: _globalSettingsVm.themeModeNotifier,
        builder: (context, themeMode, child) {
          return MaterialApp.router(
            onGenerateTitle: (context) => context.l10n.appDisplayName,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeMode,
            // locale: , // TODO: implement locale change
            localizationsDelegates: const [
              ...CommonL10n.localizationsDelegates,
              ...Localization.localizationsDelegates,
            ],
            supportedLocales: Localization.supportedLocales,
            routerConfig: _appRouter.router,
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              RootContextProvider.instance.setRootContext(context);
              return VerificationWidget(
                child: child ?? const SizedBox.shrink(),
              );

              // return StreamBuilder<BlurScreenState>(
              //   stream: _blurScreenUsecase.stateStream.distinct(),
              //   initialData: _blurScreenUsecase.currentState,
              //   builder: (context, snapshot) {
              //     final state = snapshot.data ?? BlurScreenState.unlocked;

              //     if (state != BlurScreenState.blured) {
              //       return child!;
              //     }

              //     final theme = Theme.of(context);

              //     return Stack(
              //       key: const ValueKey('blurred_screen'),
              //       children: [
              //         child!,
              //         Positioned.fill(
              //           child: AbsorbPointer(
              //             child: BackdropFilter(
              //               filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              //               child: ColoredBox(
              //                 color: theme.colorScheme.onSurfaceVariant.withValues(
              //                   alpha: 0.16,
              //                 ),
              //               ),
              //             ),
              //           ),
              //         ),
              //       ],
              //     );
              //   },
              // );
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
