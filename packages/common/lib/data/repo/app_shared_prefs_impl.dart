import 'package:common/domain/repo/app_shared_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class AppSharedPrefsImpl implements AppSharedPrefs {
  final SharedPreferences _prefs;

  AppSharedPrefsImpl(this._prefs);

  @override
  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);

  @override
  Future<void> remove(String key) => _prefs.remove(key);

  @override
  Future<void> setInt(String key, int value) => _prefs.setInt(key, value);

  @override
  String? getString(String key) => _prefs.getString(key);
  @override
  int? getInt(String key) => _prefs.getInt(key);
}
