import 'package:common/app/theme/app_theme_style.dart';
import 'package:common/domain/repo/app_shared_prefs.dart';
import 'package:common/domain/repo/app_theme_data_repo_impl.dart';
import 'package:flutter/material.dart';
import 'package:common/presentation/tools/optional_box.dart';

final class AppThemeDataRepoImpl implements AppThemeDataRepo {
  static const _keyThemeMode = 'gs_theme_mode';
  static const _keyLocaleCode = 'gs_locale_code';
  static const _keyLightThemeStyle = 'gs_light_theme_style';
  static const _keyDarkThemeStyle = 'gs_dark_theme_style';

  final AppSharedPrefs _prefs;

  AppThemeDataRepoImpl(this._prefs);

  @override
  AppThemeData load() {
    final themeModeIndex = _prefs.getInt(_keyThemeMode) ?? 0;
    final themeMode =
        ThemeMode.values[themeModeIndex.clamp(0, ThemeMode.values.length - 1)];

    return AppThemeData(
      themeMode: themeMode,
      localeCode: OptionalBox(_prefs.getString(_keyLocaleCode)),
      lightThemeStyle: _readStyle(_keyLightThemeStyle),
      darkThemeStyle: _readStyle(_keyDarkThemeStyle),
    );
  }

  AppThemeStyle _readStyle(String key) {
    final index = _prefs.getInt(key);
    if (index == null) return AppThemeStyle.defaultStyle;
    return AppThemeStyle.values[index.clamp(
      0,
      AppThemeStyle.values.length - 1,
    )];
  }

  @override
  Future<void> save(AppThemeData data) async {
    final tasks = <Future<void>>[
      _prefs.setInt(_keyThemeMode, data.themeMode.index),
      _prefs.setInt(_keyLightThemeStyle, data.lightThemeStyle.index),
      _prefs.setInt(_keyDarkThemeStyle, data.darkThemeStyle.index),
    ];

    final localeCode = data.localeCode.value;
    if (localeCode == null || localeCode.isEmpty) {
      tasks.add(_prefs.remove(_keyLocaleCode));
    } else {
      tasks.add(_prefs.setString(_keyLocaleCode, localeCode));
    }

    await Future.wait(tasks);
  }
}
