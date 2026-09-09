import 'package:nostr/model/user_keys.dart';

/// Derives the pseudonymous vault keypair used to author login-item events
/// on relays.
///
/// The derivation is deterministic from the account's private key (nsec), so
/// restoring an account on a new device recovers the vault with no extra
/// backup — and irreversible, so a relay observer cannot link the vault
/// pubkey to the account's public identity.
abstract interface class VaultIdentityUsecase {
  UserKeys execute();
}
