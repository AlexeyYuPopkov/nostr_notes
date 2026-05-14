import 'package:common/domain/repo/secure_storage.dart';

class MockSecureStorage implements SecureStorage {
  late final Map<String, String> _storage = {};

  @override
  Future<void> deleteValue({required String key}) async {
    _storage.remove(key);
  }

  @override
  Future<String> getValue({required String key}) async {
    return _storage[key] ?? '';
  }

  @override
  Future<void> setValue({required String key, required String value}) async {
    _storage[key] = value;
  }
}
