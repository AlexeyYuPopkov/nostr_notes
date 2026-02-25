import 'package:meta/meta.dart';
import 'package:nostr_notes/services/model/nostr_event.dart';

/// {@category Infrastructure}
/// {@subCategory Nostr}
///
/// Centralized READONLY place for storing all incoming events
abstract interface class RawEventStore {
  Future<void> upsert(Iterable<NostrEvent> events, {String? relayUrl});

  Future<List<NostrEvent>> queryEvents(RawEventQuery query);

  Stream<List<NostrEvent>> watchEvents(RawEventQuery query);

  /// Returns subset of [ids] that are NOT present in raw event store.
  Future<Set<String>> filterMissingEventIds(Set<String> ids);

  /// Returns subset of [pubkeys] that have NO metadata (kind 0) stored yet.
  Future<Set<String>> filterMissingPubkeys(Set<String> pubkeys);

  /// Returns subset of [dTags] that are NOT present in raw event store.
  Future<Set<String>> filterMissingDTags(Set<String> dTags);

  /// Deletes events by their IDs along with their associated tags and relay info.
  Future<void> deleteEvents(Set<String> ids);
}

/// {@category Infrastructure}
/// {@subCategory EventStore}
@immutable
class TagFilter {
  // tag[1]

  const TagFilter(this.tag, this.value);
  final String tag; // 'e', 'p', 'a', etc.
  final Iterable<String> value;
}

/// {@category Infrastructure}
/// {@subCategory Nostr}
///
/// Base class for all database queries
@immutable
class RawEventQuery {
  const RawEventQuery({
    this.ids,
    this.kinds,
    this.authors,
    this.tagFilters,
    this.hasTagTypes,
    this.since,
    this.until,
    this.limit,
    this.search,
  });

  final List<String>? ids;
  final List<int>? kinds;
  final List<String>? authors;

  /// Filter events that have tags with specific values.
  /// Example: `[TagFilter('p', ['pubkey1'])]` - events with p-tag = 'pubkey1'
  final List<TagFilter>? tagFilters;

  /// Filter events that have at least one tag of specified type(s).
  /// Example: `['p']` - events that have ANY p-tag (regardless of value)
  ///
  /// Use case: Find all events from author where they mention other users:
  /// ```dart
  /// RawEventQuery(
  ///   authors: [currentUserPubkey],
  ///   hasTagTypes: ['p'],
  /// )
  /// ```
  final List<String>? hasTagTypes;

  final DateTime? since;
  final DateTime? until;
  final int? limit;

  /// Search string for full-text search on event content.
  final String? search;

  RawEventQuery copyWith({
    List<String>? ids,
    List<int>? kinds,
    List<String>? authors,
    List<TagFilter>? tagFilters,
    List<String>? hasTagTypes,
    DateTime? since,
    DateTime? until,
    int? limit,
    String? search,
  }) {
    return RawEventQuery(
      ids: ids ?? this.ids,
      kinds: kinds ?? this.kinds,
      authors: authors ?? this.authors,
      tagFilters: tagFilters ?? this.tagFilters,
      hasTagTypes: hasTagTypes ?? this.hasTagTypes,
      since: since ?? this.since,
      until: until ?? this.until,
      limit: limit ?? this.limit,
      search: search ?? this.search,
    );
  }
}
