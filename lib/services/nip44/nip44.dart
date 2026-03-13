import 'dart:convert';
import 'dart:typed_data';

import 'package:nostr_notes/services/nip44/derive_keys.dart';
import 'package:nostr_notes/services/nip44/nip_44_utils.dart';

/// NIP-44 encryption and decryption functions.
final class Nip44 {
  const Nip44([
    DeriveKeys deriveKeys = const DeriveKeys(),
    Nip44Utils nip44Utils = const Nip44Utils(),
  ]) : _deriveKeys = deriveKeys,
       _nip44Utils = nip44Utils;

  final DeriveKeys _deriveKeys;
  final Nip44Utils _nip44Utils;

  Uint8List deriveKeys({
    required String senderPrivateKey,
    required String recipientPublicKey,
    Uint8List Function(Uint8List)? extraDerivation,
  }) {
    return _deriveKeys.execute(
      senderPrivateKey: senderPrivateKey,
      recipientPublicKey: recipientPublicKey,
      extraDerivation: extraDerivation,
    );
  }

  Future<String> encryptMessage({
    required String plaintext,
    Uint8List? customNonce,
    required Uint8List conversationKey,
  }) async {
    // Step 1: Derive Conversation Key
    final derivedConversationKey = deriveConversationKey(conversationKey);

    // Step 2: Generate or Use Custom Nonce
    final nonce = customNonce ?? _nip44Utils.secureRandomBytes(32);

    // Step 3: Derive Message Keys
    final keys = _nip44Utils.deriveMessageKeys(derivedConversationKey, nonce);
    final chachaKey = keys['chachaKey']!;
    final chachaNonce = keys['chachaNonce']!;
    final hmacKey = keys['hmacKey']!;

    // Step 4: Pad Plaintext
    final paddedPlaintext = _nip44Utils.pad(utf8.encode(plaintext));

    // Step 5: Encrypt
    final ciphertext = await _nip44Utils.encryptChaCha20(
      chachaKey,
      chachaNonce,
      paddedPlaintext,
    );

    // Step 6: Calculate MAC
    final mac = _nip44Utils.calculateMac(hmacKey, nonce, ciphertext);

    // Step 7: Construct Payload
    return _nip44Utils.constructPayload(nonce, ciphertext, mac);
  }

  Future<String> decryptMessage({
    required String payload,
    required Uint8List conversationKey,
  }) async {
    // Step 1: Derive Conversation Key

    final derivedConversationKey = deriveConversationKey(conversationKey);

    // Step 2: Parse Payload
    final parsed = _nip44Utils.parsePayload(payload);
    final nonce = parsed['nonce'];
    final ciphertext = parsed['ciphertext'];
    final mac = parsed['mac'];

    // Step 3: Derive Message Keys
    final keys = _nip44Utils.deriveMessageKeys(derivedConversationKey, nonce);
    final chachaKey = keys['chachaKey']!;
    final chachaNonce = keys['chachaNonce']!;
    final hmacKey = keys['hmacKey']!;

    // Step 4: Verify MAC
    _nip44Utils.verifyMac(hmacKey, nonce, ciphertext, mac);

    // Step 5: Decrypt
    final paddedPlaintext = await _nip44Utils.decryptChaCha20(
      chachaKey,
      chachaNonce,
      ciphertext,
    );

    // Step 6: Unpad Plaintext
    final plaintextBytes = _nip44Utils.unpad(paddedPlaintext);

    return utf8.decode(plaintextBytes);
  }

  static Uint8List deriveConversationKey(Uint8List sharedSecret) {
    final salt = utf8.encode('nip44-v2');

    final conversationKey = const Nip44Utils().hkdfExtract(
      ikm: sharedSecret,
      salt: Uint8List.fromList(salt),
    );

    return conversationKey;
  }
}
