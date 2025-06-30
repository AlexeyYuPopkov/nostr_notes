import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:nostr_notes/auth/domain/repo/crypto_repo.dart';
import 'package:nostr_notes/common/data/service/aes_encryption_with_hmac.dart';
import 'package:nostr_notes/auth/domain/repo/crypto_algorithm_type.dart';
import 'package:nostr_notes/services/key_tool/nip04_service.dart';
import 'package:nostr_notes/services/key_tool/nip44/nip44.dart';
import 'package:pointycastle/key_derivators/api.dart';
import 'package:pointycastle/key_derivators/scrypt.dart';

final class CryptoRepoImpl implements CryptoRepo {
  final Nip04Service _nip04Service;
  final AesEncryptionWithHmac _aes;

  const CryptoRepoImpl({
    Nip04Service nip04Service = const Nip04Service(),
    AesEncryptionWithHmac aes = const AesEncryptionWithHmac(),
  })  : _aes = aes,
        _nip04Service = nip04Service;

  @override
  FutureOr<String> encryptMessage({
    required String text,
    required CryptoAlgorithmType algorithmType,
  }) {
    switch (algorithmType) {
      case Nip04CryptoAlgorithmType():
        return _nip04Service.encryptNip04(
          content: text,
          privateKey: algorithmType.privateKey,
          peerPubkey: algorithmType.peerPubkey,
        );
      case Nip44CryptoAlgorithmType():
        return Nip44.encryptMessage(
          plaintext: text,
          senderPrivateKey: algorithmType.privateKey,
          recipientPublicKey: algorithmType.peerPubkey,
          customConversationKey: algorithmType.conversationKey,
        );
      case AesCryptoAlgorithmType():
        return _aes.encrypt(
          plaintext: text,
          password: algorithmType.password,
          cashedKeys: algorithmType.cashedKeys,
        );
    }
  }

  @override
  FutureOr<String> decryptMessage({
    required String text,
    required CryptoAlgorithmType algorithmType,
  }) async {
    try {
      switch (algorithmType) {
        case Nip04CryptoAlgorithmType():
          return _nip04Service.decryptNip04(
            content: text,
            privateKey: algorithmType.privateKey,
            peerPubkey: algorithmType.peerPubkey,
          );
        case Nip44CryptoAlgorithmType():
          return await Nip44.decryptMessage(
            payload: text,
            recipientPrivateKey: algorithmType.privateKey,
            senderPublicKey: algorithmType.peerPubkey,
            customConversationKey: algorithmType.conversationKey,
          );
        case AesCryptoAlgorithmType():
          return _aes.decrypt(
            ciphertext: text,
            password: algorithmType.password,
          );
      }
    } catch (e) {
      return text;
    }
  }

  @override
  FutureOr<CryptoAlgorithmType> createCache({
    required CryptoAlgorithmType algorithmType,
  }) {
    switch (algorithmType) {
      case Nip04CryptoAlgorithmType():
        throw UnimplementedError(
          ' Not implemented for Nip04 as it does not use caching',
        );
      case Nip44CryptoAlgorithmType():
        final sharedSecret = Nip44.computeSharedSecret(
          algorithmType.privateKey,
          algorithmType.peerPubkey,
        );

        final conversationKey = Nip44.deriveConversationKey(sharedSecret);

        final additionalPassword = algorithmType.additionalPassword;
        final key = additionalPassword == null
            ? conversationKey
            : generateFinalKey(
                additionalPassword,
                conversationKey,
              );

        return CryptoAlgorithmType.nip44(
          privateKey: algorithmType.privateKey,
          peerPubkey: algorithmType.peerPubkey,
          conversationKey: key,
        );
      case AesCryptoAlgorithmType():
        final sharedSecret = _aes.createCashe(algorithmType.password);
        return CryptoAlgorithmType.aes(
          password: algorithmType.password,
          cashedKeys: sharedSecret,
        );
    }
  }
}

extension on CryptoRepoImpl {
  Uint8List generateFinalKey(
    String password,
    Uint8List conversationSecret,
  ) {
    final passwordKey = _derivePasswordKey(password, conversationSecret);
    final hmac = Hmac(sha256, passwordKey);
    final digest = hmac.convert(conversationSecret);
    return Uint8List.fromList(digest.bytes);
  }

  Uint8List _derivePasswordKey(
    String password,
    Uint8List salt, {
    int keyLength = 32,
  }) {
    final scrypt = Scrypt()
      ..init(ScryptParameters(16384, 8, 1, keyLength, salt));
    return scrypt.process(utf8.encode(password));
  }
}
