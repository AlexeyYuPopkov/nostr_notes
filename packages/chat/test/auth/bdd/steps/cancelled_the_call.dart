import 'package:chat/auth/chat/data/direct_messages/chat_message_body_codec.dart';
import 'package:chat/auth/chat/domain/models/chat_message_body.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../tools/nostr/direct_message_fixtures.dart';
import 'chat_test_world.dart';

/// Usage: When {'Alice'} cancelled the call
///
/// Cancels the last invite [contact] sent me.
Future<void> cancelledTheCall(WidgetTester tester, String contact) async {
  final world = ChatTestWorld.current;
  final callId = world.lastInviteCallIds[contact];
  expect(callId, isNotNull, reason: '$contact has not invited me');
  world.relay.publish(
    await directMessage(
      from: world.contact(contact),
      to: world.me.publicKey,
      text: ChatMessageBodyCodec.encode(ChatCallCancel(callId!)),
      createdAt: DateTime.now().add(const Duration(seconds: 2)),
    ),
  );
}
