import 'package:common/domain/repo/relays_list_repo.dart';
import 'package:common/services/event_store/raw_event_store.dart';
import 'package:nostr/model/nostr_event_with_relay.dart';
import 'package:nostr/model/nostr_filter.dart';
import 'package:nostr/model/nostr_req.dart';
import 'package:nostr/nostr_client/nostr_client.dart';
import 'package:nostr_notes/auth/domain/usecase/login_items/sync_login_items_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/login_items/vault_identity_usecase.dart';
import 'package:nostr_notes/core/event_kind.dart';
import 'package:rxdart/transformers.dart';

final class SyncLoginItemsUsecaseImpl implements SyncLoginItemsUsecase {
  final NostrClient _client;
  final RawEventStore _eventStore;
  final RelaysListRepo _relaysListRepo;
  final VaultIdentityUsecase _vaultIdentityUsecase;

  const SyncLoginItemsUsecaseImpl({
    required NostrClient client,
    required RawEventStore eventStore,
    required RelaysListRepo relaysListRepo,
    required VaultIdentityUsecase vaultIdentityUsecase,
  }) : _client = client,
       _eventStore = eventStore,
       _relaysListRepo = relaysListRepo,
       _vaultIdentityUsecase = vaultIdentityUsecase;

  @override
  Stream<List<dynamic>> execute() {
    final vaultPubkey = _vaultIdentityUsecase.execute().publicKey;

    return _relaysListRepo.relaysListStream.switchMap((relays) {
      _syncRelays(relays);

      final subscriptionId = _client.sendRequestToAll(
        NostrReq(
          filters: [
            NostrFilter(
              kinds: const [NostrKind.loginItem],
              authors: [vaultPubkey],
            ),
            NostrFilter(
              kinds: const [NostrKind.deletion],
              authors: [vaultPubkey],
              additional: {
                '#k': [NostrKind.loginItem.toString()],
              },
            ),
          ],
        ),
      );

      return _client
          .stream()
          .whereType<NostrEventWithRelay>()
          .where((event) => event.subscriptionId == subscriptionId)
          .bufferTime(const Duration(milliseconds: 100))
          .where((events) => events.isNotEmpty)
          .asyncMap((events) async {
            await _eventStore.upsert(events);
            return events;
          })
          .doOnCancel(() => _client.sendCloseForAll(subscriptionId));
    });
  }

  void _syncRelays(Set<String> relays) {
    final current = _client.relaysList.toSet();
    for (final removed in current.difference(relays)) {
      _client.removeRelay(removed);
    }
    _client.addRelays(relays.difference(current));
  }
}
