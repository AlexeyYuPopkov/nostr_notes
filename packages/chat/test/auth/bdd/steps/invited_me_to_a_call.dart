import 'package:chat/auth/chat/data/direct_messages/chat_message_body_codec.dart';
import 'package:chat/auth/chat/domain/models/chat_message_body.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr/key_tool/key_tool.dart';
import 'package:webrtc_call/webrtc_call.dart';

import '../../../tools/nostr/direct_message_fixtures.dart';
import 'chat_test_world.dart';

/// Usage: Given {'Alice'} invited me to a call {'video'}
///
/// A second later than anything written before, so it is the chat's newest.
Future<void> invitedMeToACall(
  WidgetTester tester,
  String contact,
  String media,
) => publishCallInvite(
  contact: contact,
  media: media,
  at: DateTime.now().add(const Duration(seconds: 1)),
);

Future<void> publishCallInvite({
  required String contact,
  required String media,
  required DateTime at,
}) async {
  final world = ChatTestWorld.current;
  final invite = ChatCallInvite(
    callId: KeyTool.random64HexChars(),
    media: CallMedia.values.byName(media),
  );
  world.lastInviteCallIds[contact] = invite.callId;
  final event = await directMessage(
    from: world.contact(contact),
    to: world.me.publicKey,
    text: ChatMessageBodyCodec.encode(invite),
    createdAt: at,
  );
  world.relay.publish(event);
}
