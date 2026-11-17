import 'package:chat/auth/chat/domain/models/chat_message.dart';
import 'package:common/services/event_store/database/daos/outbox_dao_interface.dart';
import 'package:common/services/event_store/raw_event_store.dart';
import 'package:nostr/model/nostr_event.dart';
import 'package:nostr/model/user_keys.dart';
import 'package:rxdart/rxdart.dart';

import 'direct_message_crypto.dart';

/// Decrypted messages for store queries, marked `sending` while their event
/// is still in the outbox.
final class DirectMessagesReader {
  final RawEventStore _eventStore;
  final OutboxDaoInterface _outboxDao;
  final DirectMessageCrypto _crypto;

  const DirectMessagesReader({
    required this._eventStore,
    required this._outboxDao,
    required this._crypto,
  });

  Stream<List<ChatMessage>> watch({
    required UserKeys keys,
    required List<RawEventQuery> queries,
  }) {
    final events = Rx.combineLatestList(
      queries.map(_eventStore.watchEvents),
    ).map((lists) => lists.expand((events) => events).toList());

    // switchMap drops a decryption made stale by a newer store update.
    final messages = events.switchMap(
      (events) => Stream.fromFuture(_decrypt(keys, events)),
    );
    final undelivered = _outboxDao.watchUndelivered().map(
      (rows) => {for (final row in rows) row.eventId},
    );

    return Rx.combineLatest2(
      messages,
      undelivered,
      (messages, undeliveredIds) => [
        for (final message in messages)
          undeliveredIds.contains(message.eventId)
              ? message.copyWith(delivery: ChatMessageDelivery.sending)
              : message,
      ],
    );
  }

  Future<List<ChatMessage>> _decrypt(UserKeys keys, List<NostrEvent> events) =>
      _crypto.decrypt(keys: keys, events: events);
}
