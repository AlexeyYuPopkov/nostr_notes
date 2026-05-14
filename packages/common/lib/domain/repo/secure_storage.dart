abstract interface class SecureStorage {
  Future<String> getValue({required String key});
  Future<void> setValue({required String key, required String value});
  Future<void> deleteValue({required String key});
}
