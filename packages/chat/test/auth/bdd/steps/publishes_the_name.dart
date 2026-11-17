import 'package:flutter_test/flutter_test.dart';

import '../../../tools/nostr/direct_message_fixtures.dart';
import 'chat_test_world.dart';

/// Usage: When {'Alice'} publishes the name {'Alicia'}
///
/// A newer profile of [contact] reaches the relay while the app is running.
/// Later steps may use either name.
Future<void> publishesTheName(
  WidgetTester tester,
  String contact,
  String newName,
) async {
  final world = ChatTestWorld.current;
  world.relay.publish(
    profileEvent(
      of: world.contact(contact),
      name: newName,
      createdAt: DateTime.now().add(const Duration(minutes: 1)),
    ),
  );
  world.renameContact(contact, newName: newName);
}
