import 'package:common/app/theme/app_theme.dart';
import 'package:common/data/repo/app_theme_data_repo_impl.dart';

import 'package:common/presentation/theme_settings/global_settings_vm.dart';
import 'package:common/presentation/theme_settings/theme_settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../tools/app_launcher/app_launcher.dart';
import '../../tools/moks/app_shared_prefs_mock.dart';

void main() {
  group('ThemeSettingsScreen', () {
    late GlobalSettingsVm vm;

    setUp(() {
      vm = GlobalSettingsVm(
        appThemeDataRepo: AppThemeDataRepoImpl(AppSharedPrefsMock()),
      );
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
        AppTheme.light().scaffoldBackgroundColor,
      );

      // Tap 2-й цвет для светлой темы
      final lightBgRow = find
          .byWidgetPredicate(
            (w) =>
                w.runtimeType.toString() == '_ColorSwatchRow' &&
                w is StatelessWidget,
          )
          .first;
      final lightBgSwatch = find
          .descendant(of: lightBgRow, matching: find.byType(GestureDetector))
          .at(1); // индекс 1 — второй цвет
      await tester.tap(lightBgSwatch);
      await tester.pumpAndSettle();
      expect(vm.lightBgIndex, 1);
      expect(
        Theme.of(tester.element(screen)).scaffoldBackgroundColor,
        AppTheme.light(
          backgroundColor: const Color(0xFFFFFFFF),
        ).scaffoldBackgroundColor,
      );

      // Tap Dark Theme

      final darkRadio = find.byWidgetPredicate(
        (w) => w is Radio<ThemeMode> && w.value == ThemeMode.dark,
      );
      await tester.ensureVisible(darkRadio);
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
        AppTheme.dark().scaffoldBackgroundColor,
      );

      // Tap 3-й цвет для тёмной темы
      // Порядок _ColorSwatchRow в ListView: 0=lightBg, 1=lightCard, 2=darkBg, 3=darkCard
      final darkBgRow = find
          .byWidgetPredicate(
            (w) =>
                w.runtimeType.toString() == '_ColorSwatchRow' &&
                w is StatelessWidget,
          )
          .at(2);
      final darkBgSwatch = find
          .descendant(of: darkBgRow, matching: find.byType(GestureDetector))
          .at(2); // индекс 2 — третий цвет
      await tester.ensureVisible(darkBgSwatch);
      await tester.tap(darkBgSwatch);
      await tester.pumpAndSettle();
      expect(vm.darkBgIndex, 2);
      expect(
        Theme.of(tester.element(screen)).scaffoldBackgroundColor,
        AppTheme.dark(
          backgroundColor: const Color(0xFF18181B),
        ).scaffoldBackgroundColor,
      );
    });
  });
}
