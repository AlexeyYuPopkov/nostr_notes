import 'package:bip340/bip340.dart' as bip340;

import '../nostr_client/nostr_event_creator.dart';
import 'nostr_event.dart';

extension NostrEventVerification on NostrEvent {
  /// The id matches the content and the signature is the author's (NIP-01).
  bool get isAuthentic {
    final expectedId = const NostrEventCreator().createEventId(
      kind: kind,
      content: content,
      createdAt: createdAt,
      tags: tags,
      pubkey: pubkey,
    );
    if (expectedId != id) {
      return false;
    }
    try {
      return bip340.verify(pubkey, id, sig);
    } on Object {
      return false;
    }
  }
}
