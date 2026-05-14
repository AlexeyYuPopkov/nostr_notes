import 'package:common/domain/repo/secure_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final class SecureStorageImpl implements SecureStorage {
  static const storage = FlutterSecureStorage();
  SecureStorageImpl();

  @override
  Future<String> getValue({required String key}) async =>
      await storage.read(key: key) ?? '';

  @override
  Future<void> setValue({required String key, required String value}) async =>
      await storage.write(key: key, value: value);

  @override
  Future<void> deleteValue({required String key}) async {
    await storage.delete(key: key);
  }
}
