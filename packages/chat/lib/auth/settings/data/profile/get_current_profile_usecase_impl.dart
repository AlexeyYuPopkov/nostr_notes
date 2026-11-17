import 'package:chat/auth/common/data/model/nostr_kind.dart';
import 'package:chat/auth/settings/domain/models/profile_exception.dart';
import 'package:chat/auth/settings/domain/usecase/get_current_profile_usecase.dart';
import 'package:chat/common/domain/usecase/session_usecase.dart';
import 'package:common/data/mappers/user_mapper.dart';
import 'package:common/domain/model/user.dart';
import 'package:common/domain/repo/relays_list_repo.dart';
import 'package:common/services/event_store/raw_event_store.dart';
import 'package:nostr/model/nostr_filter.dart';
import 'package:nostr/model/nostr_req.dart';
import 'package:nostr/nostr_client/async_fetcher.dart';
import 'package:nostr/nostr_client/nostr_client.dart';
import 'package:rxdart/rxdart.dart';

import 'profile_events_helper.dart';

final class GetCurrentProfileUsecaseImpl
    with ProfileEventsHelper
    implements GetCurrentProfileUsecase {
  final SessionUsecase _sessionUsecase;
  final RawEventStore _eventStore;
  final NostrClient _client;
  final AsyncFetcher _asyncFetcher;
  final RelaysListRepo _relaysListRepo;

  const GetCurrentProfileUsecaseImpl({
    required this._sessionUsecase,
    required this._eventStore,
    required this._client,
    required this._asyncFetcher,
    required this._relaysListRepo,
  });

  @override
  Stream<User> execute() {
    final pubkey = _sessionUsecase.currentSession.pubkey;
    if (pubkey.isEmpty) {
      return Stream.error(const ProfileNoSessionException());
    }

    final storedProfile = _eventStore.watchEvents(profileQuery(pubkey)).map((
      events,
    ) {
      final event = newestProfileEvent(events);
      final user = event == null ? null : UserMapper.fromNostrEvent(event);
      return user ?? User(pubkey: pubkey);
    });
    final refresh = Stream.fromFuture(_refresh(pubkey)).ignoreElements();

    return Rx.merge([storedProfile, refresh]).distinct();
  }

  Future<void> _refresh(String pubkey) async {
    _client.syncRelays(_relaysListRepo.getRelaysList());

    final result = await _asyncFetcher.fetchEvents(
      req: NostrReq(
        filters: [
          NostrFilter(kinds: const [NostrKind.user], authors: [pubkey]),
        ],
      ),
    );

    final fetched = newestProfileEvent(result.events.values);
    if (fetched == null) {
      return;
    }

    final local = newestProfileEvent(
      await _eventStore.queryEvents(profileQuery(pubkey)),
    );
    if (local == null || fetched.createdAt > local.createdAt) {
      await _eventStore.upsert([fetched]);
    }
  }
}
