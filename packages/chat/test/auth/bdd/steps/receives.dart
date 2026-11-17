import 'package:chat/auth/common/data/model/nostr_kind.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../tools/nostr/direct_message_fixtures.dart';
import 'chat_test_world.dart';

/// Usage: Then {'Alice'} receives {'Hello'}
///
/// Decrypts what reached the relay with [contact]'s key.
Future<void> receives(WidgetTester tester, String contact, String text) async {
  final world = ChatTestWorld.current;
  final keys = world.contact(contact);
  const attempts = 50;

  for (var i = 0; i < attempts; i++) {
    for (final event in world.relay.events.where(
      (e) =>
          e.kind == NostrKind.directMessage && e.pubkey == world.me.publicKey,
    )) {
      if (await readDirectMessage(event, as: keys) == text) {
        return;
      }
    }
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }

  fail('$contact never received "$text"');
}
