import 'package:common/data/repo/key_tool_repository_impl.dart';
import 'package:common/domain/error/app_error.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_notes/common/domain/model/session/session.dart';
import 'package:nostr_notes/common/domain/usecase/auth_usecase.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';

import '../tools/mocks/mock_accounts_repo.dart';
import '../tools/mocks/mock_relays_list_repo.dart';
import '../tools/mocks/mock_secure_storage.dart';

void main() {
  const keyTool = KeyToolRepositoryImpl();

  late MockSecureStorage secureStorage;
  late MockAccountsRepo accountsRepo;
  late MockRelaysListRepo relaysListRepo;
  late SessionUsecase sessionUsecase;
  late AuthUsecase sut;

  setUp(() {
    secureStorage = MockSecureStorage();
    accountsRepo = MockAccountsRepo();
    relaysListRepo = MockRelaysListRepo.withStubRelays();
    sessionUsecase = SessionUsecase();

    sut = AuthUsecase(
      secureStorage: secureStorage,
      sessionUsecase: sessionUsecase,
      keyToolRepository: keyTool,
      relaysListRepo: relaysListRepo,
      accountsRepo: accountsRepo,
    );
  });

  tearDown(() => sessionUsecase.dispose());

  (String nsec, String pubkey) generateAccount() {
    final nsec = sut.generateNsecKey();
    final keys = keyTool.getUserKeysWithNsec(nsec: nsec);
    return (nsec, keys.publicKey);
  }

  group('AuthUsecase multi-account', () {
    test('execute registers the account and stores its key', () async {
      final (nsec, pubkey) = generateAccount();

      await sut.execute(nsec: nsec);

      expect(sut.currentSession, isA<Auth>());
      expect(sut.currentSession.pubkey, pubkey);
      expect(accountsRepo.getAccounts(), [pubkey]);
      expect(
        await secureStorage.getValue(
          key: AuthUsecase.accountStorageKey(pubkey),
        ),
        isNotEmpty,
      );
    });

    test('addAccount stores the new account and locks the session', () async {
      final (nsecA, pubkeyA) = generateAccount();
      await sut.execute(nsec: nsecA);
      sessionUsecase.setSession(
        (sut.currentSession as Auth).toUnlocked(pin: '1234'),
      );

      final (nsecB, pubkeyB) = generateAccount();
      await sut.addAccount(nsec: nsecB);

      expect(sut.currentSession, isA<Auth>());
      expect(sut.currentSession.pubkey, pubkeyB);
      expect(accountsRepo.getAccounts(), [pubkeyA, pubkeyB]);
    });

    test('switchAccount activates the stored account (locked)', () async {
      final (nsecA, pubkeyA) = generateAccount();
      final (nsecB, pubkeyB) = generateAccount();
      await sut.execute(nsec: nsecA);
      sessionUsecase.setSession(
        (sut.currentSession as Auth).toUnlocked(pin: '1234'),
      );
      await sut.addAccount(nsec: nsecB);

      await sut.switchAccount(pubkey: pubkeyA);

      expect(sut.currentSession, isA<Auth>());
      expect(sut.currentSession.pubkey, pubkeyA);
      expect(
        await secureStorage.getValue(key: AuthUsecase.secureStorageKey),
        keyTool.getUserKeysWithNsec(nsec: nsecA).privateKey,
      );
    });

    test('switchAccount to the active account is a no-op', () async {
      final (nsec, pubkey) = generateAccount();
      await sut.execute(nsec: nsec);
      sessionUsecase.setSession(
        (sut.currentSession as Auth).toUnlocked(pin: '1234'),
      );

      await sut.switchAccount(pubkey: pubkey);

      expect(sut.currentSession, isA<Unlocked>());
    });

    test('switchAccount throws and drops an account with no key', () async {
      final (nsec, _) = generateAccount();
      await sut.execute(nsec: nsec);
      await accountsRepo.addAccount('unknown-pubkey');

      await expectLater(
        sut.switchAccount(pubkey: 'unknown-pubkey'),
        throwsA(isA<AppError>()),
      );
      expect(accountsRepo.getAccounts(), isNot(contains('unknown-pubkey')));
    });

    test('restore registers a pre-multi-account key', () async {
      final (nsec, pubkey) = generateAccount();
      final keys = keyTool.getUserKeysWithNsec(nsec: nsec);
      await secureStorage.setValue(
        key: AuthUsecase.secureStorageKey,
        value: keys.privateKey,
      );

      final session = await sut.restore();

      expect(session, isA<Auth>());
      expect(accountsRepo.getAccounts(), [pubkey]);
    });

    test(
      'restore re-locks an unlocked session to the active account',
      () async {
        final (nsec, pubkey) = generateAccount();
        await sut.execute(nsec: nsec);
        sessionUsecase.setSession(
          (sut.currentSession as Auth).toUnlocked(pin: '1234'),
        );

        final session = await sut.restore();

        expect(session, isA<Auth>());
        expect(session.pubkey, pubkey);
      },
    );

    test(
      'restore(authologinIfPossible: false) locks a no-PIN account and a '
      'later plain restore() must not resurrect auto-unlock',
      () async {
        final (nsec, pubkey) = generateAccount();
        await sut.execute(nsec: nsec);
        sessionUsecase.setSession(
          (sut.currentSession as Auth).toUnlocked(pin: ''),
        );

        // The user taps Exit in settings.
        await sut.restore(authologinIfPossible: false);
        expect((sut.currentSession as Auth).authologinIfPossible, isFalse);

        // OnboardingScreen's own FutureBuilder restores again as soon as the
        // unauth zone builds — and does so with the default (true).
        await sut.restore();

        final session = sut.currentSession;
        expect(session, isA<Auth>());
        expect(session.pubkey, pubkey);
        expect(
          (session as Auth).authologinIfPossible,
          isFalse,
          reason: 'an explicit Exit must survive a redundant restore',
        );
      },
    );

    test('restore() still allows auto-unlock on a cold start', () async {
      final (nsec, _) = generateAccount();
      await sut.execute(nsec: nsec);
      // Cold start: nothing is in the session yet, only the stored key.
      sessionUsecase.setSession(const Unauth());

      await sut.restore();

      expect((sut.currentSession as Auth).authologinIfPossible, isTrue);
    });

    test(
      'switching to another account re-enables auto-unlock after an Exit',
      () async {
        final (nsecA, pubkeyA) = generateAccount();
        final (nsecB, _) = generateAccount();
        await sut.execute(nsec: nsecA);
        sessionUsecase.setSession(
          (sut.currentSession as Auth).toUnlocked(pin: ''),
        );
        // B becomes the active account, so switching back to A below is a
        // real switch rather than switchAccount's same-account no-op.
        await sut.addAccount(nsec: nsecB);
        sessionUsecase.setSession(
          (sut.currentSession as Auth).toUnlocked(pin: ''),
        );

        await sut.restore(authologinIfPossible: false);
        expect((sut.currentSession as Auth).authologinIfPossible, isFalse);

        await sut.switchAccount(pubkey: pubkeyA);

        final session = sut.currentSession;
        expect(session.pubkey, pubkeyA);
        expect(
          (session as Auth).authologinIfPossible,
          isTrue,
          reason: 'an account switch is an allowed auto-unlock trigger',
        );
      },
    );

    test('logout removes the account and activates the next one', () async {
      final (nsecA, pubkeyA) = generateAccount();
      final (nsecB, pubkeyB) = generateAccount();
      await sut.execute(nsec: nsecA);
      sessionUsecase.setSession(
        (sut.currentSession as Auth).toUnlocked(pin: '1234'),
      );
      await sut.addAccount(nsec: nsecB);

      await sut.logout();

      expect(sut.currentSession, isA<Auth>());
      expect(sut.currentSession.pubkey, pubkeyA);
      expect(accountsRepo.getAccounts(), [pubkeyA]);
      expect(
        await secureStorage.getValue(
          key: AuthUsecase.accountStorageKey(pubkeyB),
        ),
        isEmpty,
      );
      expect(relaysListRepo.getRelaysList(), isNotEmpty);
    });

    test(
      'logout(authologinIfPossible: false) leaves the fallback account '
      'locked instead of letting it auto-unlock',
      () async {
        final (nsecA, pubkeyA) = generateAccount();
        final (nsecB, _) = generateAccount();
        await sut.execute(nsec: nsecA);
        sessionUsecase.setSession(
          (sut.currentSession as Auth).toUnlocked(pin: '1234'),
        );
        await sut.addAccount(nsec: nsecB);

        await sut.logout(authologinIfPossible: false);

        final session = sut.currentSession;
        expect(session, isA<Auth>());
        expect(session.pubkey, pubkeyA);
        expect((session as Auth).authologinIfPossible, isFalse);
      },
    );

    test('logout of the last account ends with Unauth', () async {
      final (nsec, pubkey) = generateAccount();
      await sut.execute(nsec: nsec);

      await sut.logout();

      expect(sut.currentSession, isA<Unauth>());
      expect(accountsRepo.getAccounts(), isEmpty);
      expect(
        await secureStorage.getValue(
          key: AuthUsecase.accountStorageKey(pubkey),
        ),
        isEmpty,
      );
      expect(relaysListRepo.getRelaysList(), isEmpty);
    });
  });
}
