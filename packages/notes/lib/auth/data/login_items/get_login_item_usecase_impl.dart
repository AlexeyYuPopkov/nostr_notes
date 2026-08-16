import 'package:common/services/event_store/raw_event_store.dart';
import 'package:nostr/model/tag/tag.dart';
import 'package:nostr_notes/auth/data/login_items/login_item_deletions.dart';
import 'package:nostr_notes/auth/data/mappers/login_item_mapper.dart';
import 'package:nostr_notes/auth/domain/model/login_item.dart';
import 'package:nostr_notes/auth/domain/usecase/login_items/get_login_item_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/login_items/login_item_crypto_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/login_items/vault_identity_usecase.dart';
import 'package:nostr_notes/core/event_kind.dart';

final class GetLoginItemUsecaseImpl implements GetLoginItemUsecase {
  final RawEventStore _eventStore;
  final VaultIdentityUsecase _vaultIdentityUsecase;
  final LoginItemCryptoUsecase _loginItemCryptoUsecase;

  const GetLoginItemUsecaseImpl({
    required RawEventStore eventStore,
    required VaultIdentityUsecase vaultIdentityUsecase,
    required LoginItemCryptoUsecase loginItemCryptoUsecase,
  }) : _eventStore = eventStore,
       _vaultIdentityUsecase = vaultIdentityUsecase,
       _loginItemCryptoUsecase = loginItemCryptoUsecase;

  @override
  Future<LoginItem?> execute({required String dTag}) async {
    final vaultPubkey = _vaultIdentityUsecase.execute().publicKey;

    final deletedDTags = await LoginItemDeletions.deletedDTags(
      eventStore: _eventStore,
      vaultPubkey: vaultPubkey,
    );
    if (deletedDTags.contains(dTag)) {
      return null;
    }

    final events = await _eventStore.queryEvents(
      RawEventQuery(
        kinds: const [NostrKind.loginItem],
        authors: [vaultPubkey],
        tagFilters: [
          TagFilter(Tag.d.value, [dTag]),
        ],
      ),
    );

    final items = LoginItemMapper.fromNostrEvents(events);
    if (items.isEmpty) {
      return null;
    }

    final newest = items.reduce(
      (a, b) => a.createdAt.isAfter(b.createdAt) ? a : b,
    );

    try {
      return await _loginItemCryptoUsecase.decrypt(newest);
    } catch (e) {
      return LoginItem.locked(newest, e);
    }
  }
}
