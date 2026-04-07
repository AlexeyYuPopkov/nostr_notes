import 'package:common/app/vm/global_settings_scope.dart';
import 'package:common/app/vm/global_settings_vm.dart';
import 'package:common/l10n/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_notes/l10n/localization.dart';
import 'package:common/app/theme/app_theme.dart';
import 'package:common/presentation/tools/root_context_provider/root_context_provider.dart';

final globalSettingsVm = GlobalSettingsVm();

final class AppLauncher {
  static Widget launchApp({
    required Widget child,
    required WidgetTester tester,
  }) {
    return GlobalSettingsScope(
      vm: globalSettingsVm,
      child: ValueListenableBuilder(
        valueListenable: globalSettingsVm.themeModeNotifier,
        builder: (context, themeMode, _) => MaterialApp(
          onGenerateTitle: (context) => context.l10n.appDisplayName,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          localizationsDelegates: const [
            ...Localization.localizationsDelegates,
            ...CommonL10n.localizationsDelegates,
          ],
          supportedLocales: Localization.supportedLocales,
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
