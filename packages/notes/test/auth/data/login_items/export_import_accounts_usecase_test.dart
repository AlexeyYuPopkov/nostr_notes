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
        eventStore: store,
        vaultIdentityUsecase: vaultIdentity,
        loginItemCryptoUsecase: loginItemCrypto,
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
      final (_, bytes, _) = await exportSut.exportAccounts(
        password: 'backup-pw-123',
      );
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

        final (_, bytes, _) = await exportSut.exportAccounts(
          password: 'backup-pw-123',
        );
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

    test('import throws wrongPassword on a bad password', () async {
      await saveSut.execute(
        item: LoginItem.draft(title: 'GitHub', password: 'hunter2'),
      );
      final (_, bytes, _) = await exportSut.exportAccounts(
        password: 'correct-password',
      );

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

        final (_, bytes, _) = await exportSut.exportAccounts(
          password: 'backup-pw-123',
        );

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
