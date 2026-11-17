import 'package:app_test_kit/pump_helpers.dart';
import 'package:chat/auth/chat/presentation/chat/chat_screen.dart';
import 'package:chat/auth/chat/presentation/chats_list/widgets/chat_room_cell.dart';
import 'package:flutter_test/flutter_test.dart';

import 'chat_test_world.dart';
import 'i_open_the_authorized_area.dart';
import 'wait_until.dart';

/// Usage: When I open the chat with {'Alice'}
///
/// Goes the user's way: the chats list, then the conversation.
Future<void> iOpenTheChatWith(WidgetTester tester, String contact) async {
  final pubkey = ChatTestWorld.current.contact(contact).publicKey;
  await iOpenTheAuthorizedArea(tester);
  final cell = PumpHelpers.findBySemanticsId(
    ChatRoomCell.semanticsIdFor(pubkey),
  );
  await waitUntilFound(tester, cell, reason: 'the chat with $contact');
  await tester.tap(cell);
  await waitUntilFound(
    tester,
    PumpHelpers.findBySemanticsId(ChatScreen.sendButtonSemanticsId),
    reason: 'the chat with $contact to load',
  );
  await PumpHelpers.pumpFrames(tester, count: 5);
}
