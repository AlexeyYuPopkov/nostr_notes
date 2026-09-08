import 'dart:io';

import 'package:common/services/event_store/database/app_database.dart';
import 'package:common/services/event_store/raw_event_store.dart';
import 'package:di_storage/di_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_notes/auth/data/login_items/export_accounts_usecase_impl.dart';
import 'package:nostr_notes/auth/data/login_items/get_login_item_usecase_impl.dart';
import 'package:nostr_notes/auth/data/login_items/import_accounts_usecase_impl.dart';
import 'package:nostr_notes/auth/data/login_items/login_item_crypto_usecase_impl.dart';
import 'package:nostr_notes/auth/data/login_items/save_login_item_usecase_impl.dart';
import 'package:nostr_notes/auth/data/login_items/vault_identity_usecase_impl.dart';
import 'package:nostr_notes/auth/data/login_items/watch_login_items_usecase_impl.dart';
import 'package:nostr/model/tag/tag.dart';
import 'package:nostr/nostr_client/nostr_event_creator.dart';
import 'package:nostr_notes/core/event_kind.dart';
import 'package:nostr_notes/auth/domain/model/login_item.dart';
import 'package:nostr_notes/auth/domain/usecase/login_items/export_accounts_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/login_items/import_accounts_usecase.dart';
import 'package:nostr_notes/auth/domain/usecase/note_crypto_use_case.dart';
import 'package:nostr_notes/common/domain/model/session/session.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';
import 'package:nostr_notes/services/crypto_service/crypto_service.dart';

import '../../../../integration_test/di/in_memory_db_module.dart';
import '../fixtures/notes_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (call) async {
            if (call.method == 'getTemporaryDirectory') {
              return Directory.systemTemp.path;
            }
            return null;
          },
        );
  });

  group('ExportAccountsUsecaseImpl + ImportAccountsUsecaseImpl', () {
    late SessionUsecase sessionUsecase;
    late VaultIdentityUsecaseImpl vaultIdentity;
    late ExportAccountsUsecaseImpl exportSut;
    late ImportAccountsUsecaseImpl importSut;
    late SaveLoginItemUsecaseImpl saveSut;
    late GetLoginItemUsecaseImpl getSut;

    setUp(() async {
      final di = DiStorage.shared;
      const InMemoryDbModule().bind(di);

      final cryptoService = CryptoService.create(Uint8List(32));

      sessionUsecase = SessionUsecase();
      await sessionUsecase.setSession(
        const Session.unlocked(
          keys: NotesFixtures.keys,
          pin: NotesFixtures.pin,
        ),
      );

      vaultIdentity = VaultIdentityUsecaseImpl(sessionUsecase: sessionUsecase);

      final loginItemCrypto = LoginItemCryptoUsecaseImpl(
        cryptoService: cryptoService,
        sessionUsecase: sessionUsecase,
        extraDerivation: ExtraDerivation(
          cryptoService: cryptoService,
          sessionUsecase: sessionUsecase,
        ),
      );

      final RawEventStore store = di.resolve();

      saveSut = SaveLoginItemUsecaseImpl(
        eventStore: store,
        outboxDao: di.resolve(),
        vaultIdentityUsecase: vaultIdentity,
        loginItemCryptoUsecase: loginItemCrypto,
      );
      getSut = GetLoginItemUsecaseImpl(
        eventStore: store,
        vaultIdentityUsecase: vaultIdentity,
        loginItemCryptoUsecase: loginItemCrypto,
      );
      exportSut = ExportAccountsUsecaseImpl(
        watchLoginItemsUsecase: WatchLoginItemsUsecaseImpl(
          eventStore: store,
          vaultIdentityUsecase: vaultIdentity,
          loginItemCryptoUsecase: loginItemCrypto,
        ),
      );
      importSut = ImportAccountsUsecaseImpl(
        vaultIdentityUsecase: vaultIdentity,
        getLoginItemUsecase: getSut,
        saveLoginItemUsecase: saveSut,
      );
    });

    tearDown(() async {
      await sessionUsecase.dispose();
      await DiStorage.shared.resolve<AppDatabase>().close();
      DiStorage.shared.removeAll();
    });

    test('export throws passwordRequired when password is empty', () async {
      expect(
        () => exportSut.exportAccounts(password: ''),
        throwsA(
          isA<ExportAccountsError>().having(
            (e) => e.payload,
            'payload',
            ExportAccountsErrorType.passwordRequired,
          ),
        ),
      );
    });

    test('import throws passwordRequired when password is empty', () async {
      expect(
        () => importSut.importAccounts(password: '', fileBytes: Uint8List(0)),
        throwsA(
          isA<ImportAccountsError>().having(
            (e) => e.payload,
            'payload',
            ImportAccountsErrorType.passwordRequired,
          ),
        ),
      );
    });

    test('export returns empty bytes when the vault has no accounts', () async {
      final bytes = (await exportSut.exportAccounts(
        password: 'backup-pw-123',
      )).bytes;
      expect(bytes, isEmpty);
    });

    test(
      'round-trip: export then import into an empty store restores all fields',
      () async {
        final saved = await saveSut.execute(
          item: LoginItem.draft(
            title: 'GitHub',
            username: 'octocat',
            password: 'hunter2',
            websiteUrl: 'https://github.com',
            notes: 'work account',
          ),
        );

        final bytes = (await exportSut.exportAccounts(
          password: 'backup-pw-123',
        )).bytes;
        expect(bytes, isNotEmpty);

        await importSut.importAccounts(
          password: 'backup-pw-123',
          fileBytes: bytes,
        );

        final restored = await getSut.execute(dTag: saved.dTag);
        expect(restored, isNotNull);
        expect(restored!.title, 'GitHub');
        expect(restored.username, 'octocat');
        expect(restored.password, 'hunter2');
        expect(restored.websiteUrl, 'https://github.com');
        expect(restored.notes, 'work account');
      },
    );

    test(
      'a deletion that synced ahead of its item keeps it out of the backup',
      () async {
        final saved = await saveSut.execute(
          item: LoginItem.draft(title: 'GitHub', password: 'hunter2'),
        );
        final RawEventStore store = DiStorage.shared.resolve();
        final itemEvent = (await store.queryEvents(
          const RawEventQuery(kinds: [NostrKind.loginItem]),
        )).single;

        final vaultKeys = vaultIdentity.execute();
        final deletion = const NostrEventCreator().createEvent(
          kind: NostrKind.deletion,
          content: '',
          createdAt: itemEvent.createdAt.toDateTimeUtc().add(
            const Duration(seconds: 1),
          ),
          tags: [
            [
              Tag.a.value,
              '${NostrKind.loginItem}:${vaultKeys.publicKey}:${saved.dTag}',
            ],
          ],
          pubkey: vaultKeys.publicKey,
          privateKey: vaultKeys.privateKey,
        );

        // Relays hand events over in no particular order. The store applies a
        // NIP-09 request only to what it already holds, so a request that
        // arrives first deletes nothing and the item lands afterwards — stored,
        // and covered by a deletion nobody re-applies.
        await store.upsert([deletion]);
        await store.upsert([itemEvent]);
        expect(
          await store.queryEvents(
            const RawEventQuery(kinds: [NostrKind.loginItem]),
          ),
          hasLength(1),
          reason: 'sanity check: the item really is still stored',
        );

        final bytes = (await exportSut.exportAccounts(
          password: 'backup-pw-123',
        )).bytes;

        expect(
          bytes,
          isEmpty,
          reason:
              'the list already hides it — a backup that still carries it would '
              'resurrect a deleted password on the next import',
        );
      },
    );

    test('export reports accounts it could not decrypt', () async {
      await saveSut.execute(
        item: LoginItem.draft(title: 'GitHub', password: 'hunter2'),
      );
      final readable = await saveSut.execute(
        item: LoginItem.draft(title: 'Amazon', password: 'qwerty'),
      );

      // One account is left encrypted under a PIN this session does not have.
      await sessionUsecase.setSession(
        const Session.unlocked(keys: NotesFixtures.keys, pin: 'another-pin'),
      );
      final locked = await saveSut.execute(
        item: LoginItem.draft(title: 'Locked', password: 'secret'),
      );
      await sessionUsecase.setSession(
        const Session.unlocked(
          keys: NotesFixtures.keys,
          pin: NotesFixtures.pin,
        ),
      );

      final result = await exportSut.exportAccounts(password: 'backup-pw-123');

      expect(result.skippedAccounts, 1);
      expect(
        result.bytes,
        isNotEmpty,
        reason: 'the readable accounts are still backed up',
      );
      expect([readable.dTag, locked.dTag], hasLength(2));
    });

    test(
      'import keeps a stored account it cannot read rather than blanking it',
      () async {
        final saved = await saveSut.execute(
          item: LoginItem.draft(title: 'GitHub', password: 'hunter2'),
        );
        final exported = await exportSut.exportAccounts(
          password: 'backup-pw-123',
        );

        // The stored account becomes unreadable after the backup was taken.
        await sessionUsecase.setSession(
          const Session.unlocked(keys: NotesFixtures.keys, pin: 'another-pin'),
        );

        final skipped = await importSut.importAccounts(
          password: 'backup-pw-123',
          fileBytes: exported.bytes,
          policy: const LoginItemImportPolicy.keepIncoming(),
        );

        expect(skipped, 1);
        expect(
          (await getSut.execute(dTag: saved.dTag))?.error,
          isNotNull,
          reason:
              'it must still be the locked original — a policy applied against '
              'blank secrets would have written an empty password over it',
        );
      },
    );

    test('import throws wrongPassword on a bad password', () async {
      await saveSut.execute(
        item: LoginItem.draft(title: 'GitHub', password: 'hunter2'),
      );
      final bytes = (await exportSut.exportAccounts(
        password: 'correct-password',
      )).bytes;

      expect(
        () => importSut.importAccounts(
          password: 'totally-wrong-password',
          fileBytes: bytes,
        ),
        throwsA(
          isA<ImportAccountsError>().having(
            (e) => e.payload,
            'payload',
            ImportAccountsErrorType.wrongPassword,
          ),
        ),
      );
    });

    group('collision policies', () {
      Future<(LoginItem saved, Uint8List backup)>
      seedThenDivergeLocally() async {
        final saved = await saveSut.execute(
          item: LoginItem.draft(
            title: 'GitHub',
            username: 'octocat',
            password: 'orig',
          ),
        );

        final bytes = (await exportSut.exportAccounts(
          password: 'backup-pw-123',
        )).bytes;

        // Diverge the local copy under the same dTag.
        await saveSut.execute(item: saved.copyWith(password: 'diverged-local'));

        return (saved, bytes);
      }

      test(
        'keepIncoming: the backup version overwrites the local edit',
        () async {
          final (saved, bytes) = await seedThenDivergeLocally();

          await importSut.importAccounts(
            password: 'backup-pw-123',
            fileBytes: bytes,
            policy: const LoginItemImportPolicy.keepIncoming(),
          );

          final result = await getSut.execute(dTag: saved.dTag);
          expect(result!.password, 'orig');
        },
      );

      test('keepExisting: the local edit survives', () async {
        final (saved, bytes) = await seedThenDivergeLocally();

        await importSut.importAccounts(
          password: 'backup-pw-123',
          fileBytes: bytes,
          policy: const LoginItemImportPolicy.keepExisting(),
        );

        final result = await getSut.execute(dTag: saved.dTag);
        expect(result!.password, 'diverged-local');
      });

      test('keepNewest: the more recently updated version wins (the local '
          'edit, since it was saved after the backup)', () async {
        final (saved, bytes) = await seedThenDivergeLocally();

        await importSut.importAccounts(
          password: 'backup-pw-123',
          fileBytes: bytes,
          policy: const LoginItemImportPolicy.keepNewest(),
        );

        final result = await getSut.execute(dTag: saved.dTag);
        expect(result!.password, 'diverged-local');
      });
    });
  });
}

extension on int {
  DateTime toDateTimeUtc() =>
      DateTime.fromMillisecondsSinceEpoch(this * 1000, isUtc: true);
}
