import 'package:common/domain/error/app_error.dart';
import 'package:common/domain/repo/app_theme_data_repo_impl.dart';
import 'package:common/presentation/theme_settings/global_settings_vm.dart';
import 'package:common/presentation/tools/optional_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAppThemeDataRepo extends Mock implements AppThemeDataRepo {}

AppThemeData _themeData({
  ThemeMode themeMode = ThemeMode.system,
  String? localeCode,
  int lightBgIndex = 0,
  int darkBgIndex = 0,
  int lightCardIndex = 0,
  int darkCardIndex = 0,
}) {
  return AppThemeData(
    themeMode: themeMode,
    localeCode: OptionalBox(localeCode),
    lightBgIndex: lightBgIndex,
    darkBgIndex: darkBgIndex,
    lightCardIndex: lightCardIndex,
    darkCardIndex: darkCardIndex,
  );
}

void main() {
  late _MockAppThemeDataRepo repo;

  setUpAll(() {
    registerFallbackValue(_themeData());
  });

  setUp(() {
    repo = _MockAppThemeDataRepo();
  });

  group('GlobalSettingsVm construction / _parseLocale', () {
    test('null localeCode resolves to a null (system) locale', () {
      when(() => repo.load()).thenReturn(_themeData(localeCode: null));

      final vm = GlobalSettingsVm(appThemeDataRepo: repo);

      expect(vm.locale, isNull);
    });

    test('empty localeCode resolves to a null (system) locale', () {
      when(() => repo.load()).thenReturn(_themeData(localeCode: ''));

      final vm = GlobalSettingsVm(appThemeDataRepo: repo);

      expect(vm.locale, isNull);
    });

    test('bare language code resolves to a language-only locale', () {
      when(() => repo.load()).thenReturn(_themeData(localeCode: 'en'));

      final vm = GlobalSettingsVm(appThemeDataRepo: repo);

      expect(vm.locale, const Locale('en'));
    });

    test('hyphenated language-country code resolves both segments', () {
      when(() => repo.load()).thenReturn(_themeData(localeCode: 'en-US'));

      final vm = GlobalSettingsVm(appThemeDataRepo: repo);

      expect(vm.locale, const Locale('en', 'US'));
    });

    test('underscore-separated language-country code also resolves', () {
      when(() => repo.load()).thenReturn(_themeData(localeCode: 'en_US'));

      final vm = GlobalSettingsVm(appThemeDataRepo: repo);

      expect(vm.locale, const Locale('en', 'US'));
    });

    test('loads themeMode and background/card indices from the repo', () {
      when(() => repo.load()).thenReturn(
        _themeData(
          themeMode: ThemeMode.dark,
          lightBgIndex: 1,
          darkBgIndex: 2,
          lightCardIndex: 3,
          darkCardIndex: 4,
        ),
      );

      final vm = GlobalSettingsVm(appThemeDataRepo: repo);

      expect(vm.themeMode, ThemeMode.dark);
      expect(vm.lightBgIndex, 1);
      expect(vm.darkBgIndex, 2);
      expect(vm.lightCardIndex, 3);
      expect(vm.darkCardIndex, 4);
    });
  });

  group('GlobalSettingsVm.setLocale', () {
    test('saves only the language code and updates localeNotifier', () async {
      when(() => repo.load()).thenReturn(_themeData(localeCode: null));
      final vm = GlobalSettingsVm(appThemeDataRepo: repo);

      when(() => repo.save(any())).thenAnswer((_) async {});
      when(() => repo.load()).thenReturn(_themeData(localeCode: 'ru'));

      await vm.setLocale(const Locale('ru'));

      final captured = verify(() => repo.save(captureAny())).captured.single
          as AppThemeData;
      expect(captured.localeCode.value, 'ru');
      expect(vm.locale, const Locale('ru'));
    });

    test('setting locale to null persists a null localeCode (system)', () async {
      when(() => repo.load()).thenReturn(_themeData(localeCode: 'ru'));
      final vm = GlobalSettingsVm(appThemeDataRepo: repo);

      when(() => repo.save(any())).thenAnswer((_) async {});
      when(() => repo.load()).thenReturn(_themeData(localeCode: null));

      await vm.setLocale(null);

      final captured = verify(() => repo.save(captureAny())).captured.single
          as AppThemeData;
      expect(captured.localeCode.isNull, isTrue);
      expect(vm.locale, isNull);
    });

    test('leaves localeNotifier unchanged when save throws', () async {
      when(() => repo.load()).thenReturn(_themeData(localeCode: 'en'));
      final vm = GlobalSettingsVm(appThemeDataRepo: repo);

      when(() => repo.save(any())).thenThrow(Exception('disk full'));

      await vm.setLocale(const Locale('ru'));

      expect(vm.locale, const Locale('en'));
      final error = vm.errorNotifier.value;
      expect(error, isA<CustomError<GlobalSettingsError>>());
      expect((error as CustomError<GlobalSettingsError>).payload.reason,
          'Failed to save app theme data');
    });
  });

  group('LanguageCode / Locale round trip', () {
    test('LanguageCode.locale and GetLanguageCode.code are inverses', () {
      for (final code in LanguageCode.values) {
        expect(code.locale.code, code);
      }
    });

    test('unsupported locales resolve to LanguageCode.system', () {
      expect(const Locale('fr').code, LanguageCode.system);
      expect(null.code, LanguageCode.system);
    });
  });
}
