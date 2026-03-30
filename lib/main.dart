import 'dart:io';

import 'package:di_storage/di_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_notes/app/di/app_di.dart';
import 'package:nostr_notes/app/l10n/localization.dart';
import 'package:nostr_notes/app/theme/app_theme.dart';
import 'package:nostr_notes/app/router/app_router.dart';
import 'package:nostr_notes/common/data/root_context_provider/root_context_provider.dart';
import 'package:nostr_notes/services/nostr_client/outbox_publisher.dart';

import 'app/presentation/global_settings/bloc/global_settings_bloc.dart';
import 'app/presentation/global_settings/bloc/global_settings_state.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
// import 'package:nostr_notes/unauth/domain/blur_screen_usecase.dart';
// import 'package:flutter/scheduler.dart' show timeDilation;

final _appRouter = AppRouter();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  usePathUrlStrategy();

  await Di.instance.bindUnauthModules();
  HttpOverrides.global = MyHttpOverrides();
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
    return BlocProvider(
      create: (context) => GlobalSettingsBloc(),
      child: BlocBuilder<GlobalSettingsBloc, GlobalSettingsState>(
        builder: (context, state) {
          return MaterialApp.router(
            onGenerateTitle: (context) => context.l10n.appDisplayName,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: state.data.themeMode,
            // locale: , // TODO: implement locale change
            localizationsDelegates: const [
              ...Localization.localizationsDelegates,
            ],
            supportedLocales: Localization.supportedLocales,
            routerConfig: _appRouter.router,
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              RootContextProvider.instance.setRootContext(context);
              return child ?? const SizedBox.shrink();

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

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        return true;
      };
  }
}
