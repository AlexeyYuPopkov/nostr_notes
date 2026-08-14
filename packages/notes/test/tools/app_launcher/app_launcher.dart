import 'package:common/app/vm/global_settings_scope.dart';
import 'package:common/data/repo/app_theme_data_repo_impl.dart';
import 'package:common/presentation/theme_settings/global_settings_vm.dart';
import 'package:common/l10n/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_notes/l10n/localization.dart';
import 'package:common/app/theme/app_theme.dart';
import 'package:common/presentation/tools/root_context_provider/root_context_provider.dart';
import '../../../../common/test/tools/moks/app_shared_prefs_mock.dart';

final class AppLauncher {
  static Widget launchApp({
    required Widget child,
    required WidgetTester tester,
  }) {
    final globalSettingsVm = GlobalSettingsVm(
      appThemeDataRepo: AppThemeDataRepoImpl(AppSharedPrefsMock()),
    );
    addTearDown(globalSettingsVm.dispose);
    return GlobalSettingsScope(
      vm: globalSettingsVm,
      child: ListenableBuilder(
        listenable: Listenable.merge([
          globalSettingsVm.themeModeNotifier,
          globalSettingsVm.lightThemeStyleNotifier,
          globalSettingsVm.darkThemeStyleNotifier,
        ]),
        builder: (context, _) => MaterialApp(
          onGenerateTitle: (context) => context.l10n.appDisplayName,
          theme: AppTheme.light(style: globalSettingsVm.lightThemeStyle),
          darkTheme: AppTheme.dark(style: globalSettingsVm.darkThemeStyle),
          themeMode: globalSettingsVm.themeMode,
          localizationsDelegates: const [
            ...Localization.localizationsDelegates,
            ...CommonL10n.localizationsDelegates,
          ],
          supportedLocales: Localization.supportedLocales,
          debugShowCheckedModeBanner: false,
          home: Builder(
            builder: (context) {
              RootContextProvider.instance.setRootContext(context);
              return child;
            },
          ),
        ),
      ),
    );
  }
}
