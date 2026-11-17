import 'package:common/services/event_store/raw_event_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import '../../../tools/nostr/direct_message_fixtures.dart';
import 'chat_test_world.dart';

/// Usage: When {'Alice'} is now known as {'Alicia'}
///
/// A newer profile of [contact] lands in the local store, the way any other
/// screen or sync would put it there. Later steps may use either name.
Future<void> isNowKnownAs(
  WidgetTester tester,
  String contact,
  String newName,
) async {
  final world = ChatTestWorld.current;
  final profile = profileEvent(
    of: world.contact(contact),
    name: newName,
    createdAt: DateTime.now().add(const Duration(minutes: 1)),
  );
  await tester.runAsync(() => GetIt.I.get<RawEventStore>().upsert([profile]));
  world.renameContact(contact, newName: newName);
}
