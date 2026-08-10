import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// Password-based field encryption shared by every backup export/import
/// usecase (notes, accounts, …): PBKDF2 key derivation, then AES-256-CBC +
/// HMAC-SHA256 per field, with its own random IV — so the format matches
/// exactly what `decrypt_backup.py` (bundled in every backup zip) expects,
/// regardless of which content type produced it.
abstract final class BackupCryptoHelper {
  static const defaultIterations = 600000;

  static Future<SecretKey> deriveKey(
    String password,
    Uint8List salt,
    int iterations,
  ) {
    return Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iterations,
      bits: 256,
    ).deriveKeyFromPassword(password: password, nonce: salt);
  }

  static Uint8List generateRandomBytes(int length) {
    final random = math.Random.secure();
    return Uint8List.fromList(
      List.generate(length, (_) => random.nextInt(256)),
    );
  }

  static AesCbc algorithm() => AesCbc.with256bits(macAlgorithm: Hmac.sha256());

  /// Encodes as `base64(ciphertext)?iv=base64(iv)&mac=base64(mac)`. Empty
  /// input passes through unchanged (nothing to protect, nothing to derive
  /// a MAC from).
  static Future<String> encryptField(
    String text,
    SecretKey key,
    AesCbc algorithm,
  ) async {
    if (text.isEmpty) return '';
    final iv = generateRandomBytes(16);
    final secretBox = await algorithm.encrypt(
      utf8.encode(text),
      secretKey: key,
      nonce: iv,
    );
    return '${base64Encode(secretBox.cipherText)}?iv=${base64Encode(iv)}&mac=${base64Encode(secretBox.mac.bytes)}';
  }

  static Future<String> decryptField(
    String encoded,
    SecretKey key,
    AesCbc algorithm,
  ) async {
    if (encoded.isEmpty) return '';
    final parts = encoded.split('?iv=');
    final cipherText = base64Decode(parts[0]);
    final ivAndMac = parts[1].split('&mac=');
    final iv = base64Decode(ivAndMac[0]);
    final mac = Mac(base64Decode(ivAndMac[1]));
    final plainBytes = await algorithm.decrypt(
      SecretBox(cipherText, nonce: iv, mac: mac),
      secretKey: key,
    );
    return utf8.decode(plainBytes);
  }
}
