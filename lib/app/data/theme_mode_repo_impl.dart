import 'package:nostr_notes/app/domain/theme_mode_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class ThemeModeRepoImpl implements ThemeModeRepo {
  final SharedPreferences _prefs;
  static const _key = 'theme_mode_value';

  ThemeModeRepoImpl(this._prefs);

  @override
  AppThemeMode get() {
    return AppThemeMode.fromString(_prefs.getString(_key) ?? '');
  }

  @override
  Future<void> set(AppThemeMode themeMode) async {
    await _prefs.setString(_key, themeMode.toString());
  }
}
