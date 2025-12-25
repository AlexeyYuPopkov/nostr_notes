import 'dart:convert';
import 'dart:typed_data';

import 'package:nostr_notes/services/nip44/derive_keys.dart';
import 'package:nostr_notes/services/nip44/nip_44_utils.dart';

/// NIP-44 encryption and decryption functions.
final class Nip44 {
  const Nip44([DeriveKeys deriveKeys = const DeriveKeys()])
    : _deriveKeys = deriveKeys;

  final DeriveKeys _deriveKeys;

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
    final nonce = customNonce ?? secureRandomBytes(32);

    // Step 3: Derive Message Keys
    final keys = deriveMessageKeys(derivedConversationKey, nonce);
    final chachaKey = keys['chachaKey']!;
    final chachaNonce = keys['chachaNonce']!;
    final hmacKey = keys['hmacKey']!;

    // Step 4: Pad Plaintext
    final paddedPlaintext = pad(utf8.encode(plaintext));

    // Step 5: Encrypt
    final ciphertext = await encryptChaCha20(
      chachaKey,
      chachaNonce,
      paddedPlaintext,
    );

    // Step 6: Calculate MAC
    final mac = calculateMac(hmacKey, nonce, ciphertext);

    // Step 7: Construct Payload
    return constructPayload(nonce, ciphertext, mac);
  }

  Future<String> decryptMessage({
    required String payload,
    required Uint8List conversationKey,
  }) async {
    // Step 1: Derive Conversation Key

    final derivedConversationKey = deriveConversationKey(conversationKey);

    // Step 2: Parse Payload
    final parsed = parsePayload(payload);
    final nonce = parsed['nonce'];
    final ciphertext = parsed['ciphertext'];
    final mac = parsed['mac'];

    // Step 3: Derive Message Keys
    final keys = deriveMessageKeys(derivedConversationKey, nonce);
    final chachaKey = keys['chachaKey']!;
    final chachaNonce = keys['chachaNonce']!;
    final hmacKey = keys['hmacKey']!;

    // Step 4: Verify MAC
    verifyMac(hmacKey, nonce, ciphertext, mac);

    // Step 5: Decrypt
    final paddedPlaintext = await decryptChaCha20(
      chachaKey,
      chachaNonce,
      ciphertext,
    );

    // Step 6: Unpad Plaintext
    final plaintextBytes = unpad(paddedPlaintext);

    return utf8.decode(plaintextBytes);
  }

  static Uint8List deriveConversationKey(Uint8List sharedSecret) {
    final salt = utf8.encode('nip44-v2');

    final conversationKey = hkdfExtract(
      ikm: sharedSecret,
      salt: Uint8List.fromList(salt),
    );

    return conversationKey;
  }
}
