import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:nostr_notes/services/key_tool/key_tool.dart';
import 'package:nostr_notes/services/model/nostr_event.dart';

final class NostrEventCreator {
  static NostrEvent createEvent({
    required int kind,
    required String content,
    required DateTime createdAt,
    required List<List<String>> tags,
    required String pubkey,
    required String privateKey,
    List<int>? randomBytes,
  }) {
    final createdAtSeconds = (createdAt.millisecondsSinceEpoch / 1000).floor();
    final id = createEventId(
      kind: kind,
      content: content,
      createdAt: createdAtSeconds,
      tags: tags,
      pubkey: pubkey,
    );

    final sig = KeyTool.createSig(
      rawMessage: id,
      privateKey: privateKey,
      randomBytes: randomBytes,
    );

    return NostrEvent(
      kind: kind,
      id: id,
      pubkey: pubkey,
      createdAt: createdAtSeconds,
      tags: tags,
      content: content,
      sig: sig,
    );
  }

  static String createEventId({
    required int kind,
    required String content,
    required int createdAt,
    required List tags,
    required String pubkey,
  }) {
    final data = [
      0,
      pubkey,
      createdAt,
      kind,
      tags,
      content,
    ];

    final serializedEvent = jsonEncode(data);
    final bytes = utf8.encode(serializedEvent);
    final digest = sha256.convert(bytes);
    final id = hex.encode(digest.bytes);

    return id;
  }
}
