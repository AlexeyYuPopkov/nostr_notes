import 'package:common/domain/repo/fetch_event_repo.dart';
import 'package:nostr/model/nostr_event.dart';
import 'package:nostr/model/nostr_filter.dart';
import 'package:nostr/model/nostr_req.dart';
import 'package:nostr/nostr_client/nostr_client.dart';
import 'package:common/domain/model/event.dart';
import 'package:common/services/event_store/raw_event_store.dart';
import 'package:rxdart/transformers.dart';

final class FetchEventRepoImpl implements FetchEventRepo {
  final NostrClient _client;

  final RawEventStore _eventStore;

  const FetchEventRepoImpl({
    required RawEventStore eventStore,
    required NostrClient client,
  }) : _client = client,
       _eventStore = eventStore;

  @override
  Stream<Iterable<BaseEvent>> getEvents(String eventId) {
    Future.microtask(() {
      _client.sendRequestToAll(
        NostrReq(
          filters: [
            NostrFilter(ids: [eventId]),
          ],
        ),
      );
    });

    return _client
        .stream()
        .bufferTime(const Duration(milliseconds: 100))
        .where((events) => events.isNotEmpty)
        .doOnData((events) {
          _eventStore.upsert(events.whereType<NostrEvent>());
        });
  }
}
