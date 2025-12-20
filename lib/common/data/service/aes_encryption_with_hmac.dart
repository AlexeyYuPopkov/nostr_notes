import 'dart:convert';
import 'dart:math' show Random;
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/export.dart';

class AesEncryptionWithHmac {
  static const keyLength = 32; // AES-256 ключ
  static const ivLength = 16; // Размер IV для AES-CBC
  static const hmacKeyLength = 32; // HMAC-SHA256 ключ
  static const iterations = 10000; // Итерации PBKDF2

  const AesEncryptionWithHmac();

  /// Генерация ключей (AES ключ + HMAC ключ + IV) из пароля
  Map<String, Uint8List> _deriveKeys(String password, Uint8List salt) {
    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))
      ..init(
        Pbkdf2Parameters(
          salt,
          iterations,
          keyLength + ivLength + hmacKeyLength,
        ),
      );

    final keyMaterial = pbkdf2.process(
      Uint8List.fromList(utf8.encode(password)),
    );
    return {
      'aesKey': keyMaterial.sublist(0, keyLength),
      'iv': keyMaterial.sublist(keyLength, keyLength + ivLength),
      'hmacKey': keyMaterial.sublist(keyLength + ivLength),
    };
  }

  Map<String, Uint8List> createCashe(String password) {
    final salt = _generateRandomBytes(16);
    return _deriveKeys(password, salt);
  }

  /// Шифрование + HMAC
  String encrypt({
    required String plaintext,
    required String password,
    Map<String, Uint8List>? cashedKeys,
  }) {
    final salt = _generateRandomBytes(16);
    final keys = cashedKeys ?? _deriveKeys(password, salt);

    // Шифруем AES-CBC
    final encrypter = Encrypter(AES(Key(keys['aesKey']!), mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(plaintext, iv: IV(keys['iv']!));

    // Формируем данные: salt + IV + ciphertext
    final dataToHmac = Uint8List.fromList([
      ...salt,
      ...keys['iv']!,
      ...encrypted.bytes,
    ]);

    // Вычисляем HMAC-SHA256
    final hmac = HMac(SHA256Digest(), 64)..init(KeyParameter(keys['hmacKey']!));
    final hmacResult = hmac.process(dataToHmac);

    // Итоговый формат: salt + IV + ciphertext + HMAC
    final output = Uint8List.fromList([...dataToHmac, ...hmacResult]);

    return base64.encode(output);
  }

  /// Дешифрование + проверка HMAC
  String decrypt({
    required String ciphertext,
    required String password,
    Map<String, Uint8List>? cashedKeys,
  }) {
    final data = base64.decode(ciphertext);

    // Извлекаем составные части
    final salt = data.sublist(0, 16);
    final iv = data.sublist(16, 16 + ivLength);
    final ciphertextBytes = data.sublist(16 + ivLength, data.length - 32);
    final receivedHmac = data.sublist(data.length - 32);

    // Проверяем HMAC
    final keys = cashedKeys ?? _deriveKeys(password, salt);
    final dataToHmac = Uint8List.fromList([...salt, ...iv, ...ciphertextBytes]);

    final hmac = HMac(SHA256Digest(), 64)..init(KeyParameter(keys['hmacKey']!));
    final computedHmac = hmac.process(dataToHmac);

    if (!_compareHmac(receivedHmac, computedHmac)) {
      throw const HmacVerificationException();
    }

    // Если HMAC совпал, расшифровываем
    final encrypter = Encrypter(AES(Key(keys['aesKey']!), mode: AESMode.cbc));
    final decrypted = encrypter.decrypt(Encrypted(ciphertextBytes), iv: IV(iv));

    return decrypted;
  }

  /// Генерация случайных байт
  static Uint8List _generateRandomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(
      List.generate(length, (_) => random.nextInt(256)),
    );
  }

  /// Сравнение HMAC (защищённое от атак по времени)
  static bool _compareHmac(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a[i] ^ b[i];
    }
    return result == 0;
  }
}

final class HmacVerificationException implements Exception {
  String get message =>
      'Ошибка проверки HMAC: данные повреждены или пароль неверный!';

  const HmacVerificationException();

  @override
  String toString() => message;
}
