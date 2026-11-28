import 'package:chat/auth/chat/data/direct_messages/chat_message_body_codec.dart';
import 'package:chat/auth/chat/domain/models/chat_message_body.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../tools/nostr/direct_message_fixtures.dart';
import 'chat_test_world.dart';
import 'my_sent_messages.dart';

/// Usage: When {'Alice'} declines my call
///
/// Answers my invite that reached the relay with a decline.
Future<void> declinesMyCall(WidgetTester tester, String contact) async {
  final invite = await waitForMyMessageTo<ChatCallInvite>(tester, contact);
  final world = ChatTestWorld.current;
  world.relay.publish(
    await directMessage(
      from: world.contact(contact),
      to: world.me.publicKey,
      text: ChatMessageBodyCodec.encode(ChatCallDecline(invite.callId)),
      createdAt: DateTime.now().add(const Duration(seconds: 2)),
    ),
  );
}
