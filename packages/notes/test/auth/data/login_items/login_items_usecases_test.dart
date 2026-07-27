import 'dart:convert';
import 'dart:typed_data';

import 'package:common/services/event_store/database/app_database.dart';
import 'package:common/services/event_store/database/daos/outbox_dao_interface.dart';
import 'package:common/services/event_store/raw_event_store.dart';
import 'package:di_storage/di_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nostr/model/user_keys.dart';
import 'package:nostr_notes/auth/data/login_items/delete_login_item_usecase_impl.dart';
import 'package:nostr_notes/auth/data/login_items/get_login_item_usecase_impl.dart';
import 'package:nostr_notes/auth/data/login_items/login_item_crypto_usecase_impl.dart';
import 'package:nostr_notes/auth/data/login_items/save_login_item_usecase_impl.dart';
import 'package:nostr_notes/auth/data/login_items/vault_identity_usecase_impl.dart';
import 'package:nostr_notes/auth/data/login_items/watch_login_items_usecase_impl.dart';
import 'package:nostr_notes/auth/domain/model/login_item.dart';
import 'package:nostr_notes/auth/domain/usecase/note_crypto_use_case.dart';
import 'package:nostr_notes/common/domain/model/session/session.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';
import 'package:nostr_notes/services/crypto_service/crypto_service.dart';

import '../../../../integration_test/di/in_memory_db_module.dart';

const _keys = UserKeys(
  publicKey: 'bfea1ad2fdbbdd4c6d2419b3d4f63f09ad8a94d5835a7f97453eb93e860ea8fe',
  privateKey:
      'efb23a073532e28f8f3cf1b3ba4bc92f1bb6ab4dd365c853cabf9b70044e3240',
);

final class _MockCryptoService extends Mock implements CryptoService {}

/// Fake NIP-44: reversible base64 wrapping, so the round-trip exercises the
/// payload/mapper/store flow without the native crypto module. Vault key
/// derivation and event signing use the real (pure Dart) implementations.
void _stubCrypto(_MockCryptoService crypto) {
  when(
    () => crypto.deriveKeysAsync(
      senderPrivateKey: any(named: 'senderPrivateKey'),
      recipientPublicKey: any(named: 'recipientPublicKey'),
      extraDerivation: any(named: 'extraDerivation'),
    ),
  ).thenAnswer((_) async => Uint8List(32));

  when(
    () => crypto.encryptNip44(
      plaintext: any(named: 'plaintext'),
      conversationKey: any(named: 'conversationKey'),
    ),
  ).thenAnswer((invocation) async {
    final plaintext = invocation.namedArguments[#plaintext] as String;
    return 'enc:${base64Encode(utf8.encode(plaintext))}';
  });

  when(
    () => crypto.decryptNip44(
      payload: any(named: 'payload'),
      conversationKey: any(named: 'conversationKey'),
    ),
  ).thenAnswer((invocation) async {
    final payload = invocation.namedArguments[#payload] as String;
    if (!payload.startsWith('enc:')) {
      throw const FormatException('Not a fake NIP-44 payload');
    }
    return utf8.decode(base64Decode(payload.substring(4)));
  });
}

void main() {
  late SessionUsecase sessionUsecase;
  late VaultIdentityUsecaseImpl vaultIdentity;
  late SaveLoginItemUsecaseImpl save;
  late WatchLoginItemsUsecaseImpl watch;
  late GetLoginItemUsecaseImpl get;
  late DeleteLoginItemUsecaseImpl delete;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  setUp(() async {
    final di = DiStorage.shared;
    const InMemoryDbModule().bind(di);

    final crypto = _MockCryptoService();
    _stubCrypto(crypto);

    sessionUsecase = SessionUsecase();
    await sessionUsecase.setSession(
      const Session.unlocked(keys: _keys, pin: '1234'),
    );

    vaultIdentity = VaultIdentityUsecaseImpl(sessionUsecase: sessionUsecase);

    final loginItemCrypto = LoginItemCryptoUsecaseImpl(
      cryptoService: crypto,
      sessionUsecase: sessionUsecase,
      extraDerivation: ExtraDerivation(
        cryptoService: crypto,
        sessionUsecase: sessionUsecase,
      ),
    );

    final RawEventStore store = di.resolve();
    final OutboxDaoInterface outboxDao = di.resolve();
    save = SaveLoginItemUsecaseImpl(
      eventStore: store,
      outboxDao: outboxDao,
      vaultIdentityUsecase: vaultIdentity,
      loginItemCryptoUsecase: loginItemCrypto,
    );
    watch = WatchLoginItemsUsecaseImpl(
      eventStore: store,
      vaultIdentityUsecase: vaultIdentity,
      loginItemCryptoUsecase: loginItemCrypto,
    );
    get = GetLoginItemUsecaseImpl(
      eventStore: store,
      vaultIdentityUsecase: vaultIdentity,
      loginItemCryptoUsecase: loginItemCrypto,
    );
    delete = DeleteLoginItemUsecaseImpl(
      eventStore: store,
      outboxDao: outboxDao,
      vaultIdentityUsecase: vaultIdentity,
    );
  });

  tearDown(() async {
    await sessionUsecase.dispose();
    await DiStorage.shared.resolve<AppDatabase>().close();
    DiStorage.shared.removeAll();
  });

  test('vault identity is deterministic and distinct from the account', () {
    final first = vaultIdentity.execute();
    final second = vaultIdentity.execute();

    expect(first, second);
    expect(first.publicKey, isNot(_keys.publicKey));
    expect(first.privateKey, isNot(_keys.privateKey));
    expect(first.publicKey.length, 64);
  });

  test('save → watch → edit → get → delete round-trip', () async {
    final vaultPubkey = vaultIdentity.execute().publicKey;

    final draft = LoginItem.draft(
      title: 'GitHub',
      username: 'alice',
      password: 'p@ssw0rd',
      websiteUrl: 'https://github.com',
      notes: 'work account',
      image: 'https://github.com/favicon.ico',
    );

    final saved = await save.execute(item: draft);
    expect(saved.dTag, isNotEmpty);
    expect(saved.eventId, isNotEmpty);
    expect(saved.revision, 0);

    final afterSave = await watch.execute().first;
    expect(afterSave.length, 1);
    expect(afterSave.first.title, 'GitHub');
    expect(afterSave.first.username, 'alice');
    expect(afterSave.first.password, 'p@ssw0rd');
    expect(afterSave.first.websiteUrl, 'https://github.com');
    expect(afterSave.first.notes, 'work account');
    expect(afterSave.first.image, 'https://github.com/favicon.ico');
    expect(afterSave.first.error, isNull);

    // The wire event is authored by the vault identity, not the account.
    final RawEventStore store = DiStorage.shared.resolve();
    final storedEvents = await store.queryEvents(
      const RawEventQuery(kinds: [31023]),
    );
    expect(storedEvents.length, 1);
    expect(storedEvents.first.pubkey, vaultPubkey);
    expect(storedEvents.first.sig, isNotEmpty);

    final edited = await save.execute(
      item: saved.copyWith(password: 'n3w-p@ss'),
    );
    expect(edited.dTag, saved.dTag);
    expect(edited.revision, 1);
    expect(edited.createdAt.isAfter(saved.createdAt), isTrue);

    // Replaceable semantics: the edit supersedes, never duplicates.
    final afterEdit = await watch.execute().first;
    expect(afterEdit.length, 1);
    expect(afterEdit.first.password, 'n3w-p@ss');
    expect(afterEdit.first.revision, 1);

    final got = await get.execute(dTag: saved.dTag);
    expect(got, isNotNull);
    expect(got!.password, 'n3w-p@ss');

    await delete.execute(item: edited);
    expect(await watch.execute().first, isEmpty);
    expect(await get.execute(dTag: saved.dTag), isNull);
  });
}
