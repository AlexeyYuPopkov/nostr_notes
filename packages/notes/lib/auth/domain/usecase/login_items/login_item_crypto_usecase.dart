import 'package:nostr_notes/auth/domain/model/encrypted_login_item.dart';
import 'package:nostr_notes/auth/domain/model/login_item.dart';

/// Converts between the decrypted [LoginItem] and its at-rest twin
/// [EncryptedLoginItem]. Requires an `Unlocked` session (the NIP-44
/// conversation key is derived from the session keys and PIN).
abstract interface class LoginItemCryptoUsecase {
  Future<EncryptedLoginItem> encrypt(LoginItem item);

  /// Throws when the payload cannot be decrypted or has an unsupported
  /// format version; callers decide whether to surface or mark the item
  /// as locked.
  Future<LoginItem> decrypt(EncryptedLoginItem item);
}
