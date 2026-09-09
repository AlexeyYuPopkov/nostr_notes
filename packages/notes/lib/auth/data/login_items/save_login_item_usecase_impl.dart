import 'package:common/services/event_store/database/daos/outbox_dao_interface.dart';
import 'package:common/services/event_store/raw_event_store.dart';
import 'package:nostr/model/tag/tag.dart';
import 'package:nostr/nostr_client/nostr_event_creator.dart';
import 'package:nostr_notes/auth/data/mappers/login_item_mapper.dart';
import 'package:nostr_notes/auth/domain/model/login_item.dart';
import 'package:nostr_notes/auth/domain/usecase/login_items/login_item_crypto_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/login_items/save_login_item_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/login_items/vault_identity_usecase.dart';
import 'package:nostr_notes/core/event_kind.dart';
import 'package:nostr_notes/core/tools/now.dart';
import 'package:uuid/uuid.dart';

/// SQL-first, like `NotesRepositoryImpl.publishNote`: the signed vault event
/// is persisted locally, then queued so `OutboxPublisher` syncs it to relays.
final class SaveLoginItemUsecaseImpl implements SaveLoginItemUsecase {
  final RawEventStore _eventStore;
  final OutboxDaoInterface _outboxDao;
  final VaultIdentityUsecase _vaultIdentityUsecase;
  final LoginItemCryptoUsecase _loginItemCryptoUsecase;
  final NostrEventCreator _eventCreator;

  const SaveLoginItemUsecaseImpl({
    required RawEventStore eventStore,
    required OutboxDaoInterface outboxDao,
    required VaultIdentityUsecase vaultIdentityUsecase,
    required LoginItemCryptoUsecase loginItemCryptoUsecase,
    NostrEventCreator eventCreator = const NostrEventCreator(),
  }) : _eventStore = eventStore,
       _outboxDao = outboxDao,
       _vaultIdentityUsecase = vaultIdentityUsecase,
       _loginItemCryptoUsecase = loginItemCryptoUsecase,
       _eventCreator = eventCreator;

  @override
  Future<LoginItem> execute({
    required LoginItem item,
    Now? now,
    Uuid? uuid,
  }) async {
    final vaultKeys = _vaultIdentityUsecase.execute();

    final isNew = item.isNew;
    final dTag = isNew ? (uuid ?? const Uuid()).v4() : item.dTag;

    // Replaceable-event conflicts (both in the local store and on relays)
    // are resolved with second precision; an edit within the same second as
    // the stored version would otherwise be skipped as "not newer", so bump
    // past the previous created_at.
    var createdAtSeconds =
        (now?.now() ?? DateTime.now()).toUtc().millisecondsSinceEpoch ~/ 1000;
    if (!isNew) {
      final previousSeconds = item.createdAt.millisecondsSinceEpoch ~/ 1000;
      if (createdAtSeconds <= previousSeconds) {
        createdAtSeconds = previousSeconds + 1;
      }
    }
    final createdAt = DateTime.fromMillisecondsSinceEpoch(
      createdAtSeconds * 1000,
      isUtc: true,
    );

    final saved = LoginItem(
      eventId: '',
      dTag: dTag,
      title: item.title,
      username: item.username,
      password: item.password,
      websiteUrl: item.websiteUrl,
      notes: item.notes,
      image: item.image,
      totpSecret: item.totpSecret,
      revision: isNew ? 0 : item.revision + 1,
      createdAt: createdAt,
      updatedAt: createdAt,
    );

    final encrypted = await _loginItemCryptoUsecase.encrypt(saved);

    final event = _eventCreator.createEvent(
      kind: NostrKind.loginItem,
      content: encrypted.encryptedPayload,
      createdAt: createdAt,
      tags: LoginItemMapper.toTags(encrypted),
      pubkey: vaultKeys.publicKey,
      privateKey: vaultKeys.privateKey,
    );

    // Editing: drop undelivered outbox entries of the superseded version so
    // stale ciphertext is never published after the fact.
    if (!isNew) {
      final previousEvents = await _eventStore.queryEvents(
        RawEventQuery(
          kinds: const [NostrKind.loginItem],
          authors: [vaultKeys.publicKey],
          tagFilters: [
            TagFilter(Tag.d.value, [dTag]),
          ],
        ),
      );
      final oldEventIds = previousEvents
          .where((e) => e.id != event.id)
          .map((e) => e.id)
          .toSet();
      if (oldEventIds.isNotEmpty) {
        await _outboxDao.removeUndeliveredByEventIds(oldEventIds);
      }
    }

    await _eventStore.upsert([event]);
    await _outboxDao.insert(eventId: event.id);

    return LoginItem(
      eventId: event.id,
      dTag: saved.dTag,
      title: saved.title,
      username: saved.username,
      password: saved.password,
      websiteUrl: saved.websiteUrl,
      notes: saved.notes,
      image: saved.image,
      totpSecret: saved.totpSecret,
      revision: saved.revision,
      createdAt: saved.createdAt,
      updatedAt: saved.updatedAt,
    );
  }
}
