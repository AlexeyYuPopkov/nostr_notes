import 'dart:developer';

import 'package:chat/auth/common/data/model/nostr_kind.dart';
import 'package:chat/auth/chat/domain/usecase/search_contacts_fetch_usecase.dart';
import 'package:common/domain/repo/relays_list_repo.dart';
import 'package:common/services/event_store/raw_event_store.dart';
import 'package:nostr/model/nostr_filter.dart';
import 'package:nostr/model/nostr_req.dart';
import 'package:nostr/nostr_client/async_fetcher.dart';
import 'package:nostr/nostr_client/nostr_client.dart';

import 'search_contacts_helper.dart';

final class SearchContactsFetchUsecaseImpl
    with SearchContactsHelper
    implements SearchContactsFetchUsecase {
  final NostrClient _client;
  final AsyncFetcher _asyncFetcher;
  final RelaysListRepo _relaysListRepo;
  final RawEventStore _eventStore;

  const SearchContactsFetchUsecaseImpl({
    required this._client,
    required this._asyncFetcher,
    required this._relaysListRepo,
    required this._eventStore,
  });

  @override
  Future<void> execute(String query) {
    final normalized = normalize(query);
    if (normalized.isEmpty) {
      return Future.value();
    }

    final pubkey = tryParsePubkey(normalized);

    return _fetchIntoStore(pubkey: pubkey, text: normalized);
  }

  Future<void> _fetchIntoStore({
    required String? pubkey,
    required String text,
  }) async {
    final filter = pubkey == null
        ? NostrFilter(
            kinds: const [NostrKind.user],
            search: text,
            limit: SearchContactsHelper.limit,
          )
        : NostrFilter(kinds: const [NostrKind.user], authors: [pubkey]);

    _client.syncRelays(_relaysListRepo.getRelaysList());

    final result = await _asyncFetcher.fetchEvents(
      req: NostrReq(filters: [filter]),
      policy: const WaitForAllOrLimitPolicy(limit: SearchContactsHelper.limit),
    );

    // Normal for relays without NIP-50 support; logged so an empty search can
    // be told apart from relays that answered with nothing.
    if (result.error != null) {
      log(
        'Search for "$text" ended with ${result.error}, '
        'got ${result.events.length} events',
        name: runtimeType.toString(),
      );
    }

    if (result.events.isNotEmpty) {
      await _eventStore.upsert(result.events.values);
    }
  }
}
