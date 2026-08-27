import 'package:common/services/event_store/raw_event_store.dart';
import 'package:nostr/model/nostr_event.dart';
import 'package:nostr/model/nostr_filter.dart';
import 'package:nostr/model/nostr_req.dart';
import 'package:nostr/nostr_client/async_fetcher.dart';
import 'package:nostr_notes/common/data/mappers/user_mapper.dart';
import 'package:nostr_notes/common/domain/model/user.dart';
import 'package:nostr_notes/common/domain/usecase/get_user_usecase.dart';
import 'package:nostr_notes/core/event_kind.dart';

final class GetUserUsecaseImpl implements GetUserUsecase {
  static const _staleAfter = Duration(hours: 6);
  final AsyncFetcher _asyncFetcher;
  final RawEventStore _rawEventStore;

  const GetUserUsecaseImpl({
    required AsyncFetcher asyncFetcher,
    required RawEventStore rawEventStore,
  }) : _asyncFetcher = asyncFetcher,
       _rawEventStore = rawEventStore;

  @override
  Stream<User?> execute({required String pubkey, bool force = false}) async* {
    final localEvents = await _rawEventStore
        .queryEvents(
          RawEventQuery(authors: [pubkey], kinds: const [NostrKind.user]),
        )
        .then(
          (items) => items.where(
            (e) => e.kind == NostrKind.user && e.pubkey == pubkey,
          ),
        );

    final localEvent = localEvents.isEmpty ? null : localEvents.first;

    yield localEvent == null ? null : UserMapper.fromNostrEvent(localEvent);

    if (!force && localEvent != null && !_isStale(localEvent)) {
      return;
    }

    final req = NostrReq(
      filters: [
        NostrFilter(
          kinds: const [0],
          authors: [pubkey],
          since: localEvent?.createdAt,
          limit: 1,
        ),
      ],
    );

    final result = await _asyncFetcher.fetchEvents(
      req: req,
      policy: const ReturnFirstPolicy(),
    );

    if (result.events.isEmpty) {
      return;
    }

    final fetchedEvents =
        result.events.values
            .where((e) => e.kind == NostrKind.user && e.pubkey == pubkey)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final fetchedEvent = fetchedEvents.first;

    if (localEvent == null || fetchedEvent.createdAt > localEvent.createdAt) {
      await _rawEventStore.upsert([fetchedEvent]);
      yield UserMapper.fromNostrEvent(fetchedEvent);
    }
  }

  static bool _isStale(NostrEvent event) {
    final createdAt = DateTime.fromMillisecondsSinceEpoch(
      event.createdAt * 1000,
    );
    return DateTime.now().difference(createdAt) > _staleAfter;
  }
}
