import 'package:chat/auth/chat/domain/models/chat_message_body.dart';
import 'package:chat/auth/common/data/model/nostr_kind.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../tools/nostr/direct_message_fixtures.dart';
import 'chat_test_world.dart';

/// Waits until a message of mine of type [T] reaches the relay and [contact]
/// can read it.
Future<T> waitForMyMessageTo<T extends ChatMessageBody>(
  WidgetTester tester,
  String contact,
) async {
  final world = ChatTestWorld.current;
  final keys = world.contact(contact);
  const attempts = 50;

  for (var i = 0; i < attempts; i++) {
    for (final event in world.relay.events.where(
      (e) =>
          e.kind == NostrKind.directMessage && e.pubkey == world.me.publicKey,
    )) {
      if (await readDirectMessageBody(event, as: keys) case final T body) {
        return body;
      }
    }
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }

  fail('$contact never received a $T');
}
