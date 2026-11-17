import 'package:chat/auth/chat/domain/usecase/fetch_users_usecase.dart';
import 'package:chat/auth/common/data/model/nostr_kind.dart';
import 'package:collection/collection.dart';
import 'package:common/domain/repo/relays_list_repo.dart';
import 'package:common/services/event_store/raw_event_store.dart';
import 'package:nostr/model/nostr_event_with_relay.dart';
import 'package:nostr/model/nostr_filter.dart';
import 'package:nostr/model/nostr_req.dart';
import 'package:nostr/nostr_client/nostr_client.dart';
import 'package:rxdart/rxdart.dart';

final class FetchUsersUsecaseImpl implements FetchUsersUsecase {
  static const _batchWindow = Duration(milliseconds: 100);

  final RawEventStore _eventStore;
  final NostrClient _client;
  final RelaysListRepo _relaysListRepo;

  const FetchUsersUsecaseImpl({
    required this._eventStore,
    required this._client,
    required this._relaysListRepo,
  });

  @override
  Stream<void> execute({required Set<String> pubkeys}) {
    if (pubkeys.isEmpty) {
      return const Stream.empty();
    }
    return Rx.defer(() => _session(pubkeys));
  }

  Stream<void> _session(Set<String> pubkeys) {
    String? subscriptionId;

    void close() {
      final id = subscriptionId;
      if (id != null) {
        _client.sendCloseForAll(id);
        subscriptionId = null;
      }
    }

    final stored = _client
        .stream()
        .whereType<NostrEventWithRelay>()
        .where((event) => event.subscriptionId == subscriptionId)
        .bufferTime(_batchWindow)
        .where((events) => events.isNotEmpty)
        .asyncMap(_eventStore.upsert);

    // A REQ lives on the relays connected when it was sent.
    final subscribe = _client.relaysListStream
        .where((relays) => relays.isNotEmpty)
        .distinct(const SetEquality<String>().equals)
        .doOnData((_) {
          close();
          subscriptionId = _client.sendRequestToAll(
            NostrReq(
              filters: [
                NostrFilter(
                  kinds: const [NostrKind.user],
                  authors: pubkeys.toList(),
                ),
              ],
            ),
          );
        })
        .ignoreElements();

    return Rx.merge<void>([stored, subscribe])
        .doOnListen(() => _client.syncRelays(_relaysListRepo.getRelaysList()))
        .doOnCancel(close);
  }
}
