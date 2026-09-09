import 'package:common/app/theme/app_theme.dart';
import 'package:common/app/theme/app_theme_style.dart';
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

      // The light style section renders first — exactly one tile per style.
      final lightStyleGroup = find.byWidgetPredicate(
        (w) =>
            w is RadioGroup<AppThemeStyle> &&
            w.groupValue == AppThemeStyle.defaultStyle,
      );
      expect(lightStyleGroup, findsOneWidget);
      expect(
        find.descendant(
          of: lightStyleGroup,
          matching: find.byType(Radio<AppThemeStyle>),
        ),
        findsNWidgets(AppThemeStyle.values.length),
      );

      // Pick "Apple Notes" for the light style.
      final lightStyleRadios = find.descendant(
        of: lightStyleGroup,
        matching: find.byType(Radio<AppThemeStyle>),
      );
      await tester.tap(lightStyleRadios.at(1)); // Apple Notes
      await tester.pumpAndSettle();

      expect(vm.lightThemeStyle, AppThemeStyle.appleNotes);
      expect(
        Theme.of(tester.element(screen)).scaffoldBackgroundColor,
        AppTheme.light(style: AppThemeStyle.appleNotes).scaffoldBackgroundColor,
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

      // Pick "Claude" for the dark style. It's the only remaining group with
      // the default groupValue now, but it may still be offscreen (lazily
      // built by the ListView) — scroll it into view first.
      final darkStyleGroup = find.byWidgetPredicate(
        (w) =>
            w is RadioGroup<AppThemeStyle> &&
            w.groupValue == AppThemeStyle.defaultStyle,
      );
      await tester.scrollUntilVisible(
        darkStyleGroup,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      final darkStyleRadios = find.descendant(
        of: darkStyleGroup,
        matching: find.byType(Radio<AppThemeStyle>),
      );
      await tester.tap(darkStyleRadios.at(2)); // Claude
      await tester.pumpAndSettle();

      expect(vm.darkThemeStyle, AppThemeStyle.claude);
      expect(
        Theme.of(tester.element(screen)).scaffoldBackgroundColor,
        AppTheme.dark(style: AppThemeStyle.claude).scaffoldBackgroundColor,
      );
    });
  });
}
