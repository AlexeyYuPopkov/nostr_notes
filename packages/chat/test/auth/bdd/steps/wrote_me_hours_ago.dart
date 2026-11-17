import 'package:flutter_test/flutter_test.dart';

import '../../../tools/nostr/direct_message_fixtures.dart';
import 'chat_test_world.dart';

/// Usage: Given {'Alice'} wrote me {'Hi there'} {2} hours ago
///
/// Like `wrote me`, backdated: message times have one-second precision, so a
/// later message must be clearly newer to become a room's last one.
Future<void> wroteMeHoursAgo(
  WidgetTester tester,
  String contact,
  String text,
  int hours,
) async {
  final world = ChatTestWorld.current;
  final event = await directMessage(
    from: world.contact(contact),
    to: world.me.publicKey,
    text: text,
    createdAt: DateTime.now().subtract(Duration(hours: hours)),
  );
  world.relay.publish(event);
}
