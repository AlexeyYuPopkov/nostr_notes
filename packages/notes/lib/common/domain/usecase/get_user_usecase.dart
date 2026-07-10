import 'package:common/services/event_store/raw_event_store.dart';
import 'package:nostr/model/nostr_filter.dart';
import 'package:nostr/model/nostr_req.dart';
import 'package:nostr/nostr_client/async_fetcher.dart';
import 'package:nostr_notes/common/data/mappers/user_mapper.dart';
import 'package:nostr_notes/common/domain/model/user.dart';

final class GetUserUsecase {
  static const _cacheDuration = Duration(hours: 6);
  final AsyncFetcher _asyncFetcher;
  final RawEventStore _rawEventStore;
  final Map<String, _CacheEntry> _cache;

  GetUserUsecase({
    required AsyncFetcher asyncFetcher,
    required RawEventStore rawEventStore,
  }) : _asyncFetcher = asyncFetcher,
       _rawEventStore = rawEventStore,
       _cache = {};

  Future<User?> execute({required String pubkey}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final cached = _cache[pubkey];
    if (cached != null) {
      if (now - cached.timestamp <= _cacheDuration.inMilliseconds) {
        return cached.user;
      }
    }

    final localEvents = await _rawEventStore.queryEvents(
      RawEventQuery(authors: [pubkey], kinds: const [0]),
    );

    final localEvent = localEvents.isEmpty ? null : localEvents.first;
    User? localUser;

    int? since;
    if (localEvent != null) {
      since = localEvent.createdAt;
      localUser = UserMapper.fromNostrEvent(localEvent);
      if (localUser != null) {
        _cache[pubkey] = _CacheEntry(user: localUser, timestamp: now);
      }
    }

    final req = NostrReq(
      filters: [
        NostrFilter(
          kinds: const [0],
          authors: [pubkey],
          since: since,
          limit: 1,
        ),
      ],
    );

    final result = await _asyncFetcher.fetchEvents(
      req: req,
      policy: const ReturnFirstPolicy(),
    );

    if (result.events.isEmpty) {
      return localUser;
    }

    final fetchedEvents = result.events.values.toList();
    fetchedEvents.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final fetchedEvent = fetchedEvents.first;
    final fetchedUser = UserMapper.fromNostrEvent(fetchedEvent);

    if (fetchedUser != null &&
        (localEvent == null || fetchedEvent.createdAt > localEvent.createdAt)) {
      await _rawEventStore.upsert([fetchedEvent]);
      _cache[pubkey] = _CacheEntry(user: fetchedUser, timestamp: now);
      return fetchedUser;
    }

    return localUser;
  }
}

final class _CacheEntry {
  final User user;
  final int timestamp;

  const _CacheEntry({required this.user, required this.timestamp});
}
