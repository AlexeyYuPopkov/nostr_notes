import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_notes/l10n/localization.dart';
import 'package:nostr_notes/app/presentation/global_settings/bloc/global_settings_bloc.dart';
import 'package:nostr_notes/app/presentation/global_settings/bloc/global_settings_state.dart';
import 'package:nostr_notes/app/theme/app_theme.dart';
import 'package:nostr_notes/common/data/root_context_provider/root_context_provider.dart';

// class MockUserCubit extends Mock implements UserCubit {}

// class MockThemeModeManagerUsecase implements ThemeModeManagerUsecase {
//   const MockThemeModeManagerUsecase();

//   @override
//   ThemeMode get() => ThemeMode.light;

//   @override
//   void set(ThemeMode themeMode) {}
// }

final class AppLauncher {
  static Widget launchApp({
    required Widget child,
    required WidgetTester tester,
  }) {
    return BlocProvider(
      create: (context) => GlobalSettingsBloc(),
      child: BlocBuilder<GlobalSettingsBloc, GlobalSettingsState>(
        builder: (context, state) {
          return MaterialApp(
            onGenerateTitle: (context) => context.l10n.appDisplayName,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: state.data.themeMode,
            localizationsDelegates: const [
              ...Localization.localizationsDelegates,
            ],
            supportedLocales: Localization.supportedLocales,
            debugShowCheckedModeBanner: false,
            home: child,
            builder: (context, child) {
              RootContextProvider.instance.setRootContext(context);
              return child ?? const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }
}
