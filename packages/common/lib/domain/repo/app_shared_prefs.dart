abstract interface class AppSharedPrefs {
  Future<void> setString(String key, String value);

  Future<void> setInt(String key, int value);
  String? getString(String key);
  int? getInt(String key);
  Future<void> remove(String key);
}
