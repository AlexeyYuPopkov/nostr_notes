import 'package:nostr/key_tool/key_tool.dart';

mixin SearchContactsHelper {
  static const limit = 30;
  static final _hexPubkey = RegExp(r'^[0-9a-f]{64}$');

  /// The form both the relay search and the store query use; empty for a
  /// blank query.
  String normalize(String query) => query.trim().toLowerCase();

  /// Hex pubkey for an npub or a 64-char hex [query] (already normalized),
  /// `null` for anything else.
  String? tryParsePubkey(String query) {
    if (query.startsWith(KeyTool.npubPrefix)) {
      try {
        final pubkey = KeyTool.decodeNpubKeyToPublicKey(query);
        return _hexPubkey.hasMatch(pubkey) ? pubkey : null;
      } catch (_) {
        return null;
      }
    }
    return _hexPubkey.hasMatch(query) ? query : null;
  }
}
