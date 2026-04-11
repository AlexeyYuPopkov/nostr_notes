import 'package:common/app/theme/app_theme.dart';
import 'package:common/app/vm/global_settings_vm.dart';
import 'package:common/presentation/theme_settings/theme_settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../tools/app_launcher/app_launcher.dart';

void main() {
  group('ThemeSettingsScreen', () {
    late GlobalSettingsVm vm;

    setUp(() {
      vm = GlobalSettingsVm();
    });

    testWidgets('check flow', (tester) async {
      await tester.pumpWidget(
        AppLauncher.launchApp(
          child: const ThemeSettingsScreen(),
          tester: tester,
          globalSettingsVm: vm,
        ),
      );
      await tester.pumpAndSettle();

      final screen = find.byType(ThemeSettingsScreen);

      expect(find.byType(Radio<ThemeMode>), findsNWidgets(3));
      expect(vm.themeMode, ThemeMode.system);

      expect(
        find.byWidgetPredicate(
          (w) => w is RadioGroup<ThemeMode> && w.groupValue == ThemeMode.system,
        ),
        findsOneWidget,
      );

      // Tap Light Theme
      final lightRadio = find.byWidgetPredicate(
        (w) => w is Radio<ThemeMode> && w.value == ThemeMode.light,
      );
      await tester.tap(lightRadio);
      await tester.pumpAndSettle();

      expect(vm.themeMode, ThemeMode.light);
      expect(
        find.byWidgetPredicate(
          (w) => w is RadioGroup<ThemeMode> && w.groupValue == ThemeMode.light,
        ),
        findsOneWidget,
      );

      expect(
        Theme.of(tester.element(screen)).scaffoldBackgroundColor,
        AppTheme.light.scaffoldBackgroundColor,
      );

      // Tap Dark Theme

      final darkRadio = find.byWidgetPredicate(
        (w) => w is Radio<ThemeMode> && w.value == ThemeMode.dark,
      );
      await tester.tap(darkRadio);
      await tester.pumpAndSettle();

      expect(vm.themeMode, ThemeMode.dark);
      expect(
        find.byWidgetPredicate(
          (w) => w is RadioGroup<ThemeMode> && w.groupValue == ThemeMode.dark,
        ),
        findsOneWidget,
      );

      expect(
        Theme.of(tester.element(screen)).scaffoldBackgroundColor,
        AppTheme.dark.scaffoldBackgroundColor,
      );
    });
  });
}
