import 'dart:convert';

import 'package:chat/auth/chat/data/direct_messages/direct_message_crypto.dart';
import 'package:chat/auth/chat/data/direct_messages/direct_message_tags.dart';
import 'package:chat/auth/common/data/model/nostr_kind.dart';
import 'package:nostr/key_tool/key_tool.dart';
import 'package:nostr/model/nostr_event.dart';
import 'package:nostr/model/user_keys.dart';
import 'package:nostr/nostr_client/nostr_event_creator.dart';

UserKeys generateKeys() {
  final privateKey = KeyTool.random64HexChars();
  return UserKeys(
    publicKey: KeyTool.tryGetPubKey(privateKey: privateKey)!,
    privateKey: privateKey,
  );
}

/// A signed, NIP-44 encrypted direct message as another client would send it.
Future<NostrEvent> directMessage({
  required UserKeys from,
  required String to,
  required String text,
  String? id,
  DateTime? createdAt,
}) async {
  final time = createdAt ?? DateTime.now();
  final content = await DirectMessageCrypto().encrypt(
    keys: from,
    peerPubkey: to,
    text: text,
  );
  return const NostrEventCreator().createEvent(
    kind: NostrKind.directMessage,
    content: content,
    createdAt: time,
    tags: DirectMessageTags.build(
      id: id ?? KeyTool.random64HexChars(),
      peerPubkey: to,
      publishedAtSeconds:
          time.millisecondsSinceEpoch ~/ Duration.millisecondsPerSecond,
    ),
    pubkey: from.publicKey,
    privateKey: from.privateKey,
  );
}

NostrEvent profileEvent({required UserKeys of, required String name}) {
  return const NostrEventCreator().createEvent(
    kind: NostrKind.user,
    content: jsonEncode({'name': name}),
    createdAt: DateTime.now(),
    tags: const [],
    pubkey: of.publicKey,
    privateKey: of.privateKey,
  );
}

/// The text of a direct message, read the way its recipient would.
Future<String?> readDirectMessage(NostrEvent event, {required UserKeys as}) {
  return DirectMessageCrypto()
      .decrypt(keys: as, events: [event])
      .then((messages) => messages.firstOrNull?.text);
}
