import 'package:nostr_notes/common/data/service/aes_encryption_with_hmac.dart';
import 'package:nostr_notes/common/domain/repository/decryption_repository.dart';

final class DecryptionRepositoryImpl implements DecryptionRepository {
  final AesEncryptionWithHmac service;
  const DecryptionRepositoryImpl({
    this.service = const AesEncryptionWithHmac(),
  });

  @override
  Future<String> decrypt({
    required String ciphertext,
    required String password,
  }) async {
    try {
      return service.decrypt(ciphertext: ciphertext, password: password);
    } catch (e) {
      if (e is HmacVerificationException) {
        throw DecryptionRepositoryHmacException(parentError: e);
      } else {
        throw DecryptionRepositorySomethingWrongException(parentError: e);
      }
    }
  }

  @override
  Future<String> encrypt({
    required String plaintext,
    required String password,
  }) async {
    return service.encrypt(plaintext: plaintext, password: password);
  }
}
