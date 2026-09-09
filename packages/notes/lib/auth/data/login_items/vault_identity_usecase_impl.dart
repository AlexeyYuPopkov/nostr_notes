import 'dart:convert';
import 'dart:typed_data';

import 'package:common/domain/error/app_error.dart';
import 'package:crypto/crypto.dart';
import 'package:nostr/key_tool/key_tool.dart';
import 'package:nostr/model/user_keys.dart';
import 'package:nostr_notes/auth/domain/usecase/login_items/vault_identity_usecase.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';
import 'package:nostr_notes/services/hex_to_bytes.dart';

/// Vault key derivation spec (v1) — treat as frozen once events are on
/// relays; changing any constant makes existing vaults unreachable:
///
/// ```
/// ikm  = hex-decoded main private key (32 bytes)
/// salt = utf8('nostr-notes/vault/salt/v1')
/// info = utf8('nostr-notes/vault/v1') || counter   // counter starts at 0
/// vaultPrivKey = HKDF-SHA256(ikm, salt, info, 32 bytes)
/// ```
///
/// The first counter whose output is a valid secp256k1 scalar wins (the
/// chance of even one retry is negligible, but the loop makes the spec
/// total). Vault pubkey follows via BIP-340.
final class VaultIdentityUsecaseImpl implements VaultIdentityUsecase {
  static const String _saltString = 'nostr-notes/vault/salt/v1';
  static const String _infoString = 'nostr-notes/vault/v1';
  static const int _maxDerivationAttempts = 256;

  final SessionUsecase _sessionUsecase;

  const VaultIdentityUsecaseImpl({required SessionUsecase sessionUsecase})
    : _sessionUsecase = sessionUsecase;

  @override
  UserKeys execute() {
    final keys = _sessionUsecase.currentSession.keys;
    if (keys == null) {
      throw const AppError.notAuthenticated();
    }

    final ikm = HexToBytes.hexToBytes(keys.privateKey);
    final salt = utf8.encode(_saltString);
    final info = utf8.encode(_infoString);

    for (var counter = 0; counter < _maxDerivationAttempts; counter++) {
      final candidate = _hkdfSha256(
        ikm: ikm,
        salt: salt,
        info: [...info, counter],
      );

      final privateKey = HexToBytes.bytesToHex(candidate);
      final publicKey = KeyTool.tryGetPubKey(privateKey: privateKey);

      if (publicKey != null && publicKey.isNotEmpty) {
        return UserKeys(publicKey: publicKey, privateKey: privateKey);
      }
    }

    throw const AppError.common(message: 'Vault key derivation failed');
  }

  /// RFC 5869 HKDF-SHA256, single-block expand (output length == 32 bytes).
  static Uint8List _hkdfSha256({
    required Uint8List ikm,
    required List<int> salt,
    required List<int> info,
  }) {
    final prk = Hmac(sha256, salt).convert(ikm).bytes;
    final okm = Hmac(sha256, prk).convert([...info, 0x01]).bytes;
    return Uint8List.fromList(okm);
  }
}
