import 'package:flutter_test/flutter_test.dart';
import 'package:nostr/key_tool/key_tool.dart';
import 'package:nostr/model/nostr_event.dart';
import 'package:nostr/model/nostr_event_verification.dart';
import 'package:nostr/nostr_client/nostr_event_creator.dart';

void main() {
  final privateKey = KeyTool.random64HexChars();
  final pubkey = KeyTool.tryGetPubKey(privateKey: privateKey)!;
  final event = const NostrEventCreator().createEvent(
    kind: 1,
    content: 'hello',
    createdAt: DateTime(2026),
    tags: const [],
    pubkey: pubkey,
    privateKey: privateKey,
  );

  NostrEvent copy({String? content, String? sig}) => NostrEvent(
    kind: event.kind,
    id: event.id,
    pubkey: event.pubkey,
    createdAt: event.createdAt,
    tags: event.tags,
    content: content ?? event.content,
    sig: sig ?? event.sig,
  );

  test('a signed event is authentic', () {
    expect(event.isAuthentic, isTrue);
  });

  test('changed content no longer matches the id', () {
    expect(copy(content: 'tampered').isAuthentic, isFalse);
  });

  test('a signature that is not the author\'s is rejected', () {
    expect(copy(sig: 'ab' * 64).isAuthentic, isFalse);
  });
}
