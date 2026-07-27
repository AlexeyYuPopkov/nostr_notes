import 'package:collection/collection.dart';
import 'package:common/services/event_store/raw_event_store.dart';
import 'package:nostr_notes/auth/data/login_items/login_item_deletions.dart';
import 'package:nostr_notes/auth/data/mappers/login_item_mapper.dart';
import 'package:nostr_notes/auth/domain/model/encrypted_login_item.dart';
import 'package:nostr_notes/auth/domain/model/login_item.dart';
import 'package:nostr_notes/auth/domain/usecase/login_items/login_item_crypto_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/login_items/vault_identity_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/login_items/watch_login_items_usecase.dart';
import 'package:nostr_notes/core/event_kind.dart';

final class WatchLoginItemsUsecaseImpl implements WatchLoginItemsUsecase {
  final RawEventStore _eventStore;
  final VaultIdentityUsecase _vaultIdentityUsecase;
  final LoginItemCryptoUsecase _loginItemCryptoUsecase;

  const WatchLoginItemsUsecaseImpl({
    required RawEventStore eventStore,
    required VaultIdentityUsecase vaultIdentityUsecase,
    required LoginItemCryptoUsecase loginItemCryptoUsecase,
  }) : _eventStore = eventStore,
       _vaultIdentityUsecase = vaultIdentityUsecase,
       _loginItemCryptoUsecase = loginItemCryptoUsecase;

  @override
  Stream<List<LoginItem>> execute() {
    final vaultPubkey = _vaultIdentityUsecase.execute().publicKey;

    final query = RawEventQuery(
      kinds: const [NostrKind.loginItem],
      authors: [vaultPubkey],
    );

    return _eventStore.watchEvents(query).asyncMap((events) async {
      final deletedDTags = await LoginItemDeletions.deletedDTags(
        eventStore: _eventStore,
        vaultPubkey: vaultPubkey,
      );

      // The mapper drops tombstones (empty content); deletion requests
      // synced from other devices are filtered explicitly.
      final items = _newestPerDTag(
        LoginItemMapper.fromNostrEvents(events),
      ).where((item) => !deletedDTags.contains(item.dTag));

      final result = <LoginItem>[];
      for (final item in items) {
        try {
          result.add(await _loginItemCryptoUsecase.decrypt(item));
        } catch (e) {
          result.add(LoginItem.locked(item, e));
        }
      }

      return result.sorted((a, b) => b.updatedAt.compareTo(a.updatedAt));
    });
  }

  /// Defensive dedupe: the store prunes superseded replaceable events, but
  /// two versions can coexist transiently; keep the newest per d-tag.
  static List<EncryptedLoginItem> _newestPerDTag(
    List<EncryptedLoginItem> items,
  ) {
    final newest = <String, EncryptedLoginItem>{};
    for (final item in items) {
      final existing = newest[item.dTag];
      if (existing == null || item.createdAt.isAfter(existing.createdAt)) {
        newest[item.dTag] = item;
      }
    }
    return newest.values.toList();
  }
}
