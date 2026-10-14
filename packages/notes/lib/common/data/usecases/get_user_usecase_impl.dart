import 'package:common/services/event_store/raw_event_store.dart';
import 'package:nostr/model/nostr_event.dart';
import 'package:nostr/model/nostr_filter.dart';
import 'package:nostr/model/nostr_req.dart';
import 'package:nostr/nostr_client/async_fetcher.dart';
import 'package:nostr_notes/common/data/mappers/user_mapper.dart';
import 'package:nostr_notes/common/domain/model/user.dart';
import 'package:nostr_notes/common/domain/usecase/get_user_usecase.dart';
import 'package:nostr_notes/core/event_kind.dart';
import 'package:rxdart/rxdart.dart';

final class GetUserUsecaseImpl implements GetUserUsecase {
  static const _staleAfter = Duration(hours: 6);
  final AsyncFetcher _asyncFetcher;
  final RawEventStore _rawEventStore;

  const GetUserUsecaseImpl({
    required this._asyncFetcher,
    required this._rawEventStore,
  });

  @override
  Stream<User?> execute({required String pubkey, bool force = false}) {
    final storedUser = _rawEventStore
        .watchEvents(_userQuery(pubkey))
        .map((events) => _newestUser(events, pubkey));
    final refresh = Stream.fromFuture(
      _refresh(pubkey: pubkey, force: force),
    ).ignoreElements();
    return Rx.merge([storedUser, refresh]).distinct();
  }

  Future<void> _refresh({required String pubkey, required bool force}) async {
    final localEvents = await _rawEventStore.queryEvents(_userQuery(pubkey));
    final localEvent = _newestEvent(localEvents, pubkey);

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

    final fetchedEvent = _newestEvent(result.events.values, pubkey);

    if (fetchedEvent == null) {
      return;
    }

    if (localEvent == null || fetchedEvent.createdAt > localEvent.createdAt) {
      await _rawEventStore.upsert([fetchedEvent]);
    }
  }

  static RawEventQuery _userQuery(String pubkey) =>
      RawEventQuery(authors: [pubkey], kinds: const [NostrKind.user]);

  static NostrEvent? _newestEvent(Iterable<NostrEvent> events, String pubkey) {
    final userEvents = events
        .where((e) => e.kind == NostrKind.user && e.pubkey == pubkey)
        .toList();
    if (userEvents.isEmpty) return null;
    return userEvents.reduce((a, b) => a.createdAt >= b.createdAt ? a : b);
  }

  static User? _newestUser(Iterable<NostrEvent> events, String pubkey) {
    final event = _newestEvent(events, pubkey);
    return event == null ? null : UserMapper.fromNostrEvent(event);
  }

  static bool _isStale(NostrEvent event) {
    final createdAt = DateTime.fromMillisecondsSinceEpoch(
      event.createdAt * 1000,
    );
    return DateTime.now().difference(createdAt) > _staleAfter;
  }
}
