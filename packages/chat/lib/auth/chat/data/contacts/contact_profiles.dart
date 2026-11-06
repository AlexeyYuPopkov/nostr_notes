import 'package:chat/auth/common/data/model/nostr_kind.dart';
import 'package:collection/collection.dart';
import 'package:common/data/mappers/user_mapper.dart';
import 'package:common/domain/model/user.dart';
import 'package:common/domain/repo/relays_list_repo.dart';
import 'package:common/services/event_store/raw_event_store.dart';
import 'package:nostr/model/nostr_event.dart';
import 'package:nostr/model/nostr_filter.dart';
import 'package:nostr/model/nostr_req.dart';
import 'package:nostr/nostr_client/async_fetcher.dart';
import 'package:nostr/nostr_client/nostr_client.dart';
import 'package:rxdart/rxdart.dart';

/// Kind 0 profiles of chat peers: read from the store, fetched from relays
/// once for pubkeys the store has no profile of.
final class ContactProfiles {
  final RawEventStore _eventStore;
  final NostrClient _client;
  final AsyncFetcher _asyncFetcher;
  final RelaysListRepo _relaysListRepo;

  const ContactProfiles({
    required this._eventStore,
    required this._client,
    required this._asyncFetcher,
    required this._relaysListRepo,
  });

  /// Every pubkey of [pubkeys] maps to a [User], bare until its kind 0 is
  /// stored.
  Stream<Map<String, User>> watch(Set<String> pubkeys) {
    if (pubkeys.isEmpty) {
      return Stream.value(const {});
    }

    final stored = _eventStore
        .watchEvents(
          RawEventQuery(
            kinds: const [NostrKind.user],
            authors: pubkeys.toList(),
          ),
        )
        .map((events) => _profiles(pubkeys, events))
        .distinct(const MapEquality<String, User>().equals);
    final fetch = Stream.fromFuture(_fetchMissing(pubkeys)).ignoreElements();

    return Rx.merge([stored, fetch]);
  }

  Future<void> _fetchMissing(Set<String> pubkeys) async {
    final missing = await _eventStore.filterMissingPubkeys(pubkeys);
    if (missing.isEmpty) {
      return;
    }

    _client.syncRelays(_relaysListRepo.getRelaysList());
    final result = await _asyncFetcher.fetchEvents(
      req: NostrReq(
        filters: [
          NostrFilter(kinds: const [NostrKind.user], authors: missing.toList()),
        ],
      ),
    );
    if (result.events.isNotEmpty) {
      await _eventStore.upsert(result.events.values);
    }
  }

  static Map<String, User> _profiles(
    Set<String> pubkeys,
    Iterable<NostrEvent> events,
  ) {
    final newest = <String, NostrEvent>{};
    for (final event in events) {
      final current = newest[event.pubkey];
      if (current == null || event.createdAt > current.createdAt) {
        newest[event.pubkey] = event;
      }
    }

    return {
      for (final pubkey in pubkeys)
        pubkey:
            switch (newest[pubkey]) {
              final event? => UserMapper.fromNostrEvent(event),
              null => null,
            } ??
            User(pubkey: pubkey),
    };
  }
}
