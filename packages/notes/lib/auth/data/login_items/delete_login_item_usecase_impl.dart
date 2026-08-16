import 'package:common/services/event_store/database/daos/outbox_dao_interface.dart';
import 'package:common/services/event_store/raw_event_store.dart';
import 'package:nostr/model/tag/tag.dart';
import 'package:nostr/model/tag/tag_value.dart';
import 'package:nostr/nostr_client/nostr_event_creator.dart';
import 'package:nostr_notes/auth/domain/model/login_item.dart';
import 'package:nostr_notes/auth/domain/usecase/login_items/delete_login_item_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/login_items/vault_identity_usecase.dart';
import 'package:nostr_notes/core/event_kind.dart';
import 'package:nostr_notes/core/tools/now.dart';

/// Mirrors `NotesRepositoryImpl.deleteNote`: publishes an empty-content
/// tombstone (so the replaceable slot is overwritten even on relays that
/// ignore NIP-09) plus a kind-5 deletion request, both signed by the vault
/// key and queued through the outbox.
final class DeleteLoginItemUsecaseImpl implements DeleteLoginItemUsecase {
  final RawEventStore _eventStore;
  final OutboxDaoInterface _outboxDao;
  final VaultIdentityUsecase _vaultIdentityUsecase;
  final NostrEventCreator _eventCreator;
  final Now _now;

  const DeleteLoginItemUsecaseImpl({
    required RawEventStore eventStore,
    required OutboxDaoInterface outboxDao,
    required VaultIdentityUsecase vaultIdentityUsecase,
    NostrEventCreator eventCreator = const NostrEventCreator(),
    Now now = const Now(),
  }) : _eventStore = eventStore,
       _outboxDao = outboxDao,
       _vaultIdentityUsecase = vaultIdentityUsecase,
       _eventCreator = eventCreator,
       _now = now;

  @override
  Future<void> execute({required LoginItem item}) async {
    if (item.dTag.isEmpty) {
      return;
    }

    final vaultKeys = _vaultIdentityUsecase.execute();

    // Strictly after the stored version at second precision, so the
    // tombstone supersedes it locally and on relays.
    var createdAtSeconds =
        _now.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    final previousSeconds = item.createdAt.millisecondsSinceEpoch ~/ 1000;
    if (createdAtSeconds <= previousSeconds) {
      createdAtSeconds = previousSeconds + 1;
    }
    final createdAt = DateTime.fromMillisecondsSinceEpoch(
      createdAtSeconds * 1000,
      isUtc: true,
    );

    final tombstone = _eventCreator.createEvent(
      kind: NostrKind.loginItem,
      content: '',
      createdAt: createdAt,
      tags: [
        [Tag.d.value, item.dTag],
      ],
      pubkey: vaultKeys.publicKey,
      privateKey: vaultKeys.privateKey,
    );

    final deletion = _eventCreator.createEvent(
      kind: NostrKind.deletion,
      content: '',
      createdAt: createdAt,
      tags: [
        if (item.eventId.isNotEmpty) [TagValue.e, item.eventId],
        [
          TagValue.a,
          ATag(
            kind: NostrKind.loginItem,
            pubkey: vaultKeys.publicKey,
            dTag: item.dTag,
          ).toTagString(),
        ],
        [Tag.k.value, NostrKind.loginItem.toString()],
      ],
      pubkey: vaultKeys.publicKey,
      privateKey: vaultKeys.privateKey,
    );

    // Never publish a superseded version after the deletion.
    final previousEvents = await _eventStore.queryEvents(
      RawEventQuery(
        kinds: const [NostrKind.loginItem],
        authors: [vaultKeys.publicKey],
        tagFilters: [
          TagFilter(Tag.d.value, [item.dTag]),
        ],
      ),
    );
    final oldEventIds = previousEvents.map((e) => e.id).toSet();
    if (oldEventIds.isNotEmpty) {
      await _outboxDao.removeUndeliveredByEventIds(oldEventIds);
    }

    await _eventStore.upsert([tombstone, deletion]);
    await _outboxDao.insert(eventId: tombstone.id);
    await _outboxDao.insert(eventId: deletion.id);
  }
}
