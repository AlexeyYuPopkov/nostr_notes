import 'package:chat/auth/common/data/model/nostr_kind.dart';
import 'package:chat/auth/chat/domain/usecase/search_contacts_get_usecase.dart';
import 'package:collection/collection.dart';
import 'package:common/data/mappers/user_mapper.dart';
import 'package:common/domain/model/user.dart';
import 'package:common/services/event_store/raw_event_store.dart';
import 'package:nostr/model/nostr_event.dart';

import 'search_contacts_helper.dart';

final class SearchContactsGetUsecaseImpl
    with SearchContactsHelper
    implements SearchContactsGetUsecase {
  final RawEventStore _eventStore;

  const SearchContactsGetUsecaseImpl({required this._eventStore});

  @override
  Stream<List<User>> execute(String searchStr) {
    final normalized = normalize(searchStr);
    if (normalized.isEmpty) {
      return Stream.value(const []);
    }

    final pubkey = tryParsePubkey(normalized);

    final query = pubkey == null
        ? RawEventQuery(
            kinds: const [NostrKind.user],
            search: normalized,
            limit: SearchContactsHelper.limit,
          )
        : RawEventQuery(
            kinds: const [NostrKind.user],
            authors: [pubkey],
            limit: 1,
          );

    return _eventStore
        .watchEvents(query)
        .map((events) {
          final users = _newestProfiles(events);
          if (pubkey != null && users.isEmpty) {
            return [User(pubkey: pubkey)];
          }
          return users;
        })
        // Drift re-runs the query on any write to the events table.
        .distinct(const ListEquality<User>().equals);
  }

  static List<User> _newestProfiles(Iterable<NostrEvent> events) {
    final newestByPubkey = <String, NostrEvent>{};

    for (final event in events) {
      final current = newestByPubkey[event.pubkey];
      if (current == null || event.createdAt > current.createdAt) {
        newestByPubkey[event.pubkey] = event;
      }
    }

    return newestByPubkey.values
        .map(UserMapper.fromNostrEvent)
        .whereType<User>()
        .toList();
  }
}
