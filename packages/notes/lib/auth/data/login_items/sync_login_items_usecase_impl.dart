import 'package:common/domain/repo/relays_list_repo.dart';
import 'package:common/services/event_store/raw_event_store.dart';
import 'package:nostr/model/nostr_filter.dart';
import 'package:nostr/model/nostr_req.dart';
import 'package:nostr/nostr_client/async_fetcher.dart';
import 'package:nostr/nostr_client/nostr_client.dart';
import 'package:nostr_notes/auth/domain/usecase/login_items/sync_login_items_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/login_items/vault_identity_usecase.dart';
import 'package:nostr_notes/core/event_kind.dart';

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
  Future<int> execute() async {
    final vaultPubkey = _vaultIdentityUsecase.execute().publicKey;

    _client.addRelays(_relaysListRepo.getRelaysList());

    final result = await AsyncFetcher(client: _client).fetchEvents(
      req: NostrReq(
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

    if (result.events.isNotEmpty) {
      await _eventStore.upsert(result.events.values);
    }

    return result.events.length;
  }
}
