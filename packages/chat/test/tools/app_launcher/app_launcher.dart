import 'package:common/app/vm/global_settings_scope.dart';
import 'package:common/app/vm/global_settings_vm.dart';
import 'package:common/l10n/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:common/app/theme/app_theme.dart';
import 'package:common/presentation/tools/root_context_provider/root_context_provider.dart';

final _globalSettingsVm = GlobalSettingsVm();

final class AppLauncher {
  static Widget launchApp({
    required Widget child,
    required WidgetTester tester,
    GlobalSettingsVm? globalSettingsVm,
  }) {
    final globSettingsVm = globalSettingsVm ?? _globalSettingsVm;
    return GlobalSettingsScope(
      vm: globSettingsVm,
      child: ValueListenableBuilder(
        valueListenable: globSettingsVm.themeModeNotifier,
        builder: (context, themeMode, _) => MaterialApp(
          // onGenerateTitle: (context) => context.l10n.appDisplayName,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          localizationsDelegates: const [...CommonL10n.localizationsDelegates],
          supportedLocales: CommonL10n.supportedLocales,
          debugShowCheckedModeBanner: false,
          // home: child,
          builder: (context, _) {
            RootContextProvider.instance.setRootContext(context);
            return child;
          },
        ),
      ),
    );
  }
}
