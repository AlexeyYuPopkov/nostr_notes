import 'package:common/domain/repo/app_shared_prefs.dart';

class AppSharedPrefsMock implements AppSharedPrefs {
  final _storage = <String, Object>{};

  @override
  Future<void> setInt(String key, int value) async {
    _storage[key] = value;
  }

  @override
  Future<void> setString(String key, String value) async {
    _storage[key] = value;
  }

  @override
  String? getString(String key) => _storage[key] as String?;
  @override
  int? getInt(String key) => _storage[key] as int?;
  @override
  Future<void> remove(String key) async {
    _storage.remove(key);
  }
}
