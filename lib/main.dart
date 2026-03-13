import 'dart:io';
import 'dart:ui';

import 'package:di_storage/di_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:nostr_notes/app/di/app_di.dart';
import 'package:nostr_notes/app/l10n/localization.dart';
import 'package:nostr_notes/app/theme/app_theme.dart';
import 'package:nostr_notes/app/router/app_router.dart';
import 'package:nostr_notes/common/data/root_context_provider/root_context_provider.dart';
import 'package:nostr_notes/services/nostr_client/outbox_publisher.dart';
import 'package:nostr_notes/unauth/domain/blur_screen_usecase.dart';

final _appRouter = AppRouter();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Di.instance.bindUnauthModules();
  HttpOverrides.global = MyHttpOverrides();
  runApp(const App());
}

final class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

final class _AppState extends State<App> with WidgetsBindingObserver {
  late final BlurScreenUsecase _blurScreenUsecase = DiStorage.shared.resolve();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      DiStorage.shared.tryResolve<OutboxPublisher>()?.resume();
      _blurScreenUsecase.onForeground();
    }

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused) {
      DiStorage.shared.tryResolve<OutboxPublisher>()?.pause();
      _blurScreenUsecase.onBackground();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.appDisplayName,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      localizationsDelegates: const [
        ...Localization.localizationsDelegates,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: Localization.supportedLocales,
      routerConfig: _appRouter.router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        RootContextProvider.instance.setRootContext(context);

        return StreamBuilder<BlurScreenState>(
          stream: _blurScreenUsecase.stateStream,
          initialData: _blurScreenUsecase.currentState,
          builder: (context, snapshot) {
            final state = snapshot.data ?? BlurScreenState.unlocked;

            if (state != BlurScreenState.blured) {
              return child!;
            }

            final theme = Theme.of(context);

            return Stack(
              children: [
                child!,
                Positioned.fill(
                  child: AbsorbPointer(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                      child: ColoredBox(
                        color: theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
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
