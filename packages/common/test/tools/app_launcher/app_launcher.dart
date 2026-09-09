import 'package:common/app/vm/global_settings_scope.dart';
import 'package:common/data/repo/app_theme_data_repo_impl.dart';
import 'package:common/presentation/theme_settings/global_settings_vm.dart';
import 'package:common/l10n/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:common/app/theme/app_theme.dart';
import 'package:common/presentation/tools/root_context_provider/root_context_provider.dart';

import '../moks/app_shared_prefs_mock.dart';

final class AppLauncher {
  static Widget launchApp({
    required Widget child,
    required WidgetTester tester,
    GlobalSettingsVm? globalSettingsVm,
  }) {
    final globSettingsVm =
        globalSettingsVm ??
        GlobalSettingsVm(
          appThemeDataRepo: AppThemeDataRepoImpl(AppSharedPrefsMock()),
        );
    return GlobalSettingsScope(
      vm: globSettingsVm,
      child: ListenableBuilder(
        listenable: Listenable.merge([
          globSettingsVm.themeModeNotifier,
          globSettingsVm.lightThemeStyleNotifier,
          globSettingsVm.darkThemeStyleNotifier,
        ]),
        builder: (context, _) => MaterialApp(
          theme: AppTheme.light(style: globSettingsVm.lightThemeStyle),
          darkTheme: AppTheme.dark(style: globSettingsVm.darkThemeStyle),
          themeMode: globSettingsVm.themeMode,
          localizationsDelegates: const [...CommonL10n.localizationsDelegates],
          supportedLocales: CommonL10n.supportedLocales,
          debugShowCheckedModeBanner: false,
          builder: (context, _) {
            RootContextProvider.instance.setRootContext(context);
            return child;
          },
        ),
      ),
    );
  }
}
