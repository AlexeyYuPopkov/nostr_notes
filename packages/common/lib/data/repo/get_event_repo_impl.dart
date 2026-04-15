import 'package:nostr/model/nostr_event.dart';
import 'package:common/domain/repo/get_event_repo.dart';
import 'package:common/services/event_store/raw_event_store.dart';

final class GetEventRepoImpl implements GetEventRepo {
  final RawEventStore _eventStore;

  const GetEventRepoImpl({required RawEventStore eventStore})
    : _eventStore = eventStore;

  @override
  Future<NostrEvent> getEvent(String eventId) async {
    final events = await _eventStore.queryEvents(RawEventQuery(ids: [eventId]));
    if (events.isEmpty) throw Exception('Event not found: $eventId');
    return events.first;
  }

  Future<Set<String>> getEventRelays(String eventId) async {
    final events = await _eventStore.queryEvents(RawEventQuery(ids: [eventId]));
    if (events.isEmpty) return {};
    return _eventStore.eventRelays(events.first);
  }
}
