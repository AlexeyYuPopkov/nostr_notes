import 'package:nostr_notes/core/one_to_many_map.dart';
import 'package:nostr_notes/core/tools/disposable.dart';
import 'package:nostr_notes/services/model/nostr_event.dart';
import 'package:nostr_notes/services/model/tag/tag.dart';
import 'package:nostr_notes/services/model/tag/tag_value.dart';
import 'package:rxdart/rxdart.dart';

abstract class CommonEventStorage {
  Stream<NostrEvent> get eventsStream;
  void addAll(Iterable<NostrEvent> events);
  void add(NostrEvent event);
  NostrEvent? getById(String id);
  NostrEvent? getEventsByATag(String aTag, int kind);
  Iterable<NostrEvent> getEventsByPTag(String pTag, int kind);
  Iterable<NostrEvent> getEventsByTTag(String tTag, int kind);
  Iterable<NostrEvent> getEventsByAuthor(String author, int kind);
}

final class OneToLatest {
  final Map<String, NostrEvent> _storage = {};

  NostrEvent? add(String key, NostrEvent event) {
    final old = _storage[key];
    if (old != null && old.createdAt > event.createdAt) {
      return null;
    }
    _storage[key] = event;

    return old;
  }

  NostrEvent? get({required String key}) => _storage[key];
}

class CommonEventStorageImpl implements CommonEventStorage, Disposable {
  static final instance = CommonEventStorageImpl();

  final Map<String, NostrEvent> _storage = {};

  /// key - kind, value - nostr event id
  final OneToManyMap kindIndexes = OneToManyMap();

  /// key - a-tag, value - nostr event id
  final OneToLatest aTagIndexes = OneToLatest();

  /// key - p-tag, value - nostr event id
  final OneToManyMap pTagIndexes = OneToManyMap();

  /// key - t-tag, value - nostr event id
  final OneToManyMap tTagIndexes = OneToManyMap();

  /// key - t-tag, value - nostr event id
  final OneToManyMap authorIndexes = OneToManyMap();

  final _eventsStream = PublishSubject<NostrEvent>();

  @override
  Stream<NostrEvent> get eventsStream => _eventsStream;

  CommonEventStorageImpl();

  @override
  void addAll(Iterable<NostrEvent> events) {
    for (final event in events) {
      add(event);
    }
  }

  @override
  void add(NostrEvent event) {
    _eventsStream.add(event);
    _storage[event.id] = event;

    kindIndexes.add(key: event.kind.toString(), value: event.id);

    final dTag = event.getFirstTag(Tag.d);

    if (dTag != null && dTag.isNotEmpty) {
      final aTag = TagValue.createATag(
        kind: event.kind,
        pubkey: event.pubkey,
        dTag: dTag,
      );
      final old = aTagIndexes.add(aTag, event);

      if (old != null && old.id != event.id) {
        _storage.remove(old.id);
      }
    }

    final pTags = event.getTagsSet(Tag.p);

    if (pTags.isNotEmpty) {
      for (final pTag in pTags) {
        if (pTag.isNotEmpty) {
          pTagIndexes.add(key: pTag, value: event.id);
        }
      }
    }

    final tTags = event.getTagsSet(Tag.t);

    if (tTags.isNotEmpty) {
      for (final tTag in tTags) {
        if (tTags.isNotEmpty) {
          tTagIndexes.add(key: tTag, value: event.id);
        }
      }
    }

    final author = event.pubkey;
    if (author.isNotEmpty) {
      authorIndexes.add(key: author, value: event.id);
    }

    // _eventsStream.add(event);
  }

  @override
  NostrEvent? getEventsByATag(String aTag, int kind) {
    final result = aTagIndexes.get(key: aTag);
    return result;
  }

  @override
  Iterable<NostrEvent> getEventsByPTag(String pTag, int kind) {
    final eventIds = pTagIndexes.get(key: pTag);
    return eventIds.map((e) => _storage[e]).nonNulls.where(
          (e) => e.kind == kind,
        );
  }

  @override
  Iterable<NostrEvent> getEventsByTTag(String tTag, int kind) {
    final eventIds = tTagIndexes.get(key: tTag);
    return eventIds.map((e) => _storage[e]).nonNulls.where(
          (e) => e.kind == kind,
        );
  }

  @override
  Iterable<NostrEvent> getEventsByAuthor(String author, int kind) {
    final eventIds = authorIndexes.get(key: author);
    return eventIds.map((e) => _storage[e]).nonNulls.where(
          (e) => e.kind == kind,
        );
  }

  @override
  NostrEvent? getById(String id) => _storage[id];

  @override
  Future<void> dispose() {
    return _eventsStream.close();
  }
}
