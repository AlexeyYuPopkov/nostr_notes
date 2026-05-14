import 'package:common/domain/repo/app_shared_prefs.dart';
import 'package:common/domain/repo/app_theme_data_repo_impl.dart';
import 'package:flutter/material.dart';

final class AppThemeDataRepoImpl implements AppThemeDataRepo {
  static const _keyThemeMode = 'gs_theme_mode';
  static const _keyLightBgIndex = 'gs_light_bg_index';
  static const _keyDarkBgIndex = 'gs_dark_bg_index';
  static const _keyLightCardIndex = 'gs_light_card_index';
  static const _keyDarkCardIndex = 'gs_dark_card_index';

  final AppSharedPrefs _prefs;

  AppThemeDataRepoImpl(this._prefs);

  @override
  AppThemeData load() {
    final themeModeIndex = _prefs.getInt(_keyThemeMode) ?? 0;
    final themeMode =
        ThemeMode.values[themeModeIndex.clamp(0, ThemeMode.values.length - 1)];

    return AppThemeData(
      themeMode: themeMode,
      lightBgIndex: _prefs.getInt(_keyLightBgIndex) ?? 0,
      darkBgIndex: _prefs.getInt(_keyDarkBgIndex) ?? 0,
      lightCardIndex: _prefs.getInt(_keyLightCardIndex) ?? 0,
      darkCardIndex: _prefs.getInt(_keyDarkCardIndex) ?? 0,
    );
  }

  @override
  Future<void> save(AppThemeData data) async {
    await Future.wait([
      _prefs.setInt(_keyThemeMode, data.themeMode.index),
      _prefs.setInt(_keyLightBgIndex, data.lightBgIndex),
      _prefs.setInt(_keyDarkBgIndex, data.darkBgIndex),
      _prefs.setInt(_keyLightCardIndex, data.lightCardIndex),
      _prefs.setInt(_keyDarkCardIndex, data.darkCardIndex),
    ]);
  }
}
