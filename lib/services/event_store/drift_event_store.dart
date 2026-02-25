import 'package:nostr_notes/services/event_store/database/daos/nostr_event_dao.dart';
import 'package:nostr_notes/services/event_store/raw_event_store.dart';
import 'package:nostr_notes/services/model/nostr_event.dart';

/// {@category Infrastructure}
/// {@subCategory EventStore}
///
/// [RawEventStore] implementation with drift
class DriftEventStore implements RawEventStore {
  const DriftEventStore({required NostrEventDao dao}) : _dao = dao;
  final NostrEventDao _dao;

  @override
  Future<void> upsert(Iterable<NostrEvent> events, {String? relayUrl}) {
    return _dao.upsertEvents(events, relayUrl: relayUrl);
  }

  @override
  Future<List<NostrEvent>> queryEvents(RawEventQuery query) {
    return _dao.queryEvents(query);
  }

  @override
  Stream<List<NostrEvent>> watchEvents(RawEventQuery query) {
    return _dao.watchEvents(query);
  }

  @override
  Future<Set<String>> filterMissingEventIds(Set<String> ids) {
    return _dao.filterMissingEventIds(ids);
  }

  @override
  Future<Set<String>> filterMissingPubkeys(Set<String> pubkeys) {
    return _dao.filterMissingPubkeys(pubkeys);
  }

  @override
  Future<Set<String>> filterMissingDTags(Set<String> dTags) {
    return _dao.filterMissingDTags(dTags);
  }

  @override
  Future<void> deleteEvents(Set<String> ids) {
    return _dao.deleteEvents(ids);
  }
}
