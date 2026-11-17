import 'package:flutter_test/flutter_test.dart';

import '../../../tools/nostr/direct_message_fixtures.dart';
import 'chat_test_world.dart';

/// Usage: Given {'Alice'} wrote me {'Hi there'}
///
/// The message waits on the relay; [contact] gets a profile there too.
Future<void> wroteMe(WidgetTester tester, String contact, String text) async {
  final world = ChatTestWorld.current;
  final event = await directMessage(
    from: world.contact(contact),
    to: world.me.publicKey,
    text: text,
  );
  world.relay.publish(event);
}
