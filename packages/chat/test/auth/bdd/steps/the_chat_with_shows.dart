import 'package:app_test_kit/pump_helpers.dart';
import 'package:chat/auth/chat/presentation/chats_list/widgets/chat_room_cell.dart';
import 'package:flutter_test/flutter_test.dart';

import 'chat_test_world.dart';
import 'wait_until.dart';

/// Usage: Then the chat with {'Alice'} shows {'Hi there'}
///
/// Waits for the relay's messages and profile to reach the list.
Future<void> theChatWithShows(
  WidgetTester tester,
  String contact,
  String lastMessage,
) async {
  final pubkey = ChatTestWorld.current.contact(contact).publicKey;
  final cell = PumpHelpers.findBySemanticsId(
    ChatRoomCell.semanticsIdFor(pubkey),
  );
  Finder inCell(String text) =>
      find.descendant(of: cell, matching: find.text(text));

  await waitUntilFound(
    tester,
    inCell(contact),
    reason: 'the chat named $contact',
  );
  expect(inCell(lastMessage), findsOneWidget);
}
