import 'dart:convert';
import 'dart:developer';

import 'package:nostr/model/nostr_event.dart';
import 'package:nostr_notes/common/domain/model/user.dart';

final class UserMapper {
  static const int _metadataKind = 0;

  static User? fromNostrEvent(NostrEvent event) {
    if (event.kind != _metadataKind) {
      return null;
    }

    try {
      final json = jsonDecode(event.content) as Map<String, dynamic>;
      return User.fromJson(pubkey: event.pubkey, json: json);
    } catch (e, stackTrace) {
      log(
        'Failed to parse User from NostrEvent: ${event.id}',
        error: e,
        stackTrace: stackTrace,
        name: 'UserMapper',
      );
      return null;
    }
  }
}
