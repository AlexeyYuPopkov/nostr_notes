import 'package:chat/auth/common/data/model/nostr_kind.dart';
import 'package:common/services/event_store/database/app_database.dart';
import 'package:common/services/event_store/database/daos/outbox_dao_interface.dart';
import 'package:common/services/event_store/raw_event_store.dart';
import 'package:nostr/model/user_keys.dart';
import 'package:nostr/nostr_client/nostr_event_creator.dart';

import 'direct_message_crypto.dart';
import 'direct_message_tags.dart';

/// Encrypts, signs and stores a message version, queueing it in the outbox
/// in the same transaction so a stored message is never left unsent.
final class DirectMessageWriter {
  final AppDatabase _database;
  final RawEventStore _eventStore;
  final OutboxDaoInterface _outboxDao;
  final DirectMessageCrypto _crypto;
  final NostrEventCreator _eventCreator;

  const DirectMessageWriter({
    required this._database,
    required this._eventStore,
    required this._outboxDao,
    required this._crypto,
    this._eventCreator = const NostrEventCreator(),
  });

  Future<void> write({
    required UserKeys keys,
    required String id,
    required String peerPubkey,
    required String text,
    required int publishedAtSeconds,
    required DateTime createdAt,
    Set<String> replacedEventIds = const {},
  }) async {
    final content = await _crypto.encrypt(
      keys: keys,
      peerPubkey: peerPubkey,
      text: text,
    );
    final event = _eventCreator.createEvent(
      kind: NostrKind.directMessage,
      content: content,
      createdAt: createdAt,
      tags: DirectMessageTags.build(
        id: id,
        peerPubkey: peerPubkey,
        publishedAtSeconds: publishedAtSeconds,
      ),
      pubkey: keys.publicKey,
      privateKey: keys.privateKey,
    );

    await _database.transaction(() async {
      if (replacedEventIds.isNotEmpty) {
        await _outboxDao.removeUndeliveredByEventIds(replacedEventIds);
      }
      await _eventStore.upsert([event]);
      await _outboxDao.insert(eventId: event.id);
    });
  }
}
