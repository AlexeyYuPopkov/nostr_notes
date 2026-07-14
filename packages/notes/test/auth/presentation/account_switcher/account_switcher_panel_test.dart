import 'package:common/data/repo/key_tool_repository_impl.dart';
import 'package:common/services/event_store/database/app_database.dart';
import 'package:common/services/event_store/raw_event_store.dart';
import 'package:di_storage/di_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr/nostr_client/async_fetcher.dart';
import 'package:nostr/nostr_client/nostr_client.dart';
import 'package:nostr_notes/auth/domain/repo/accounts_repo.dart';
import 'package:nostr_notes/auth/presentation/account_switcher/account_switcher_panel.dart';
import 'package:nostr_notes/common/presentation/account_avatar.dart';
import 'package:nostr_notes/common/domain/model/session/session.dart';
import 'package:nostr_notes/common/domain/usecase/auth_usecase.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';
import 'package:nostr_notes/common/data/usecases/get_user_usecase_impl.dart';
import 'package:nostr_notes/common/domain/usecase/get_user_usecase.dart';

import '../../../../integration_test/di/in_memory_db_module.dart';
import '../../../tools/app_launcher/app_launcher.dart';
import '../../../tools/mocks/mock_accounts_repo.dart';
import '../../../tools/mocks/mock_relays_list_repo.dart';
import '../../../tools/mocks/mock_secure_storage.dart';

void main() {
  const keyTool = KeyToolRepositoryImpl();

  late MockSecureStorage secureStorage;
  late MockAccountsRepo accountsRepo;
  late SessionUsecase sessionUsecase;
  late AuthUsecase authUsecase;

  setUp(() {
    secureStorage = MockSecureStorage();
    accountsRepo = MockAccountsRepo();
    sessionUsecase = SessionUsecase();

    authUsecase = AuthUsecase(
      secureStorage: secureStorage,
      sessionUsecase: sessionUsecase,
      keyToolRepository: keyTool,
      relaysListRepo: MockRelaysListRepo.withStubRelays(),
      accountsRepo: accountsRepo,
    );

    final di = DiStorage.shared;
    di.bind<SessionUsecase>(
      () => sessionUsecase,
      module: null,
      lifeTime: const LifeTime.single(),
    );
    di.bind<AuthUsecase>(
      () => authUsecase,
      module: null,
      lifeTime: const LifeTime.single(),
    );
    di.bind<AccountsRepo>(
      () => accountsRepo,
      module: null,
      lifeTime: const LifeTime.single(),
    );

    const InMemoryDbModule().bind(di);
    di.bind<GetUserUsecase>(
      () => GetUserUsecaseImpl(
        // No relays are added, so AsyncFetcher.fetchEvents short-circuits
        // with an empty result without touching the network.
        asyncFetcher: AsyncFetcher(client: NostrClient()),
        rawEventStore: di.resolve<RawEventStore>(),
      ),
      module: null,
      lifeTime: const LifeTime.prototype(),
    );
  });

  tearDown(() async {
    final AppDatabase db = DiStorage.shared.resolve();
    await db.close();
    DiStorage.shared.removeAll();
  });

  Future<(String, String)> setUpTwoAccounts() async {
    final nsecA = authUsecase.generateNsecKey();
    final nsecB = authUsecase.generateNsecKey();
    final pubkeyA = keyTool.getUserKeysWithNsec(nsec: nsecA).publicKey;
    final pubkeyB = keyTool.getUserKeysWithNsec(nsec: nsecB).publicKey;

    await authUsecase.execute(nsec: nsecA);
    sessionUsecase.setSession(
      (sessionUsecase.currentSession as Auth).toUnlocked(pin: '1234'),
    );
    await authUsecase.addAccount(nsec: nsecB);
    sessionUsecase.setSession(
      (sessionUsecase.currentSession as Auth).toUnlocked(pin: '1234'),
    );

    return (pubkeyA, pubkeyB);
  }

  group('AccountSwitcherPanel', () {
    testWidgets('shows all accounts with the current one checked', (
      tester,
    ) async {
      final (pubkeyA, pubkeyB) = await setUpTwoAccounts();

      await tester.pumpWidget(
        AppLauncher.launchApp(
          tester: tester,
          child: const AccountSwitcherPanel(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AccountAvatar), findsNWidgets(2));
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(sessionUsecase.currentSession.pubkey, pubkeyB);
      expect(accountsRepo.getAccounts(), [pubkeyA, pubkeyB]);
    });

    testWidgets('tap on another account locks the session with its keys', (
      tester,
    ) async {
      final (pubkeyA, pubkeyB) = await setUpTwoAccounts();

      await tester.pumpWidget(
        AppLauncher.launchApp(
          tester: tester,
          child: const AccountSwitcherPanel(),
        ),
      );
      await tester.pumpAndSettle();

      // The unchecked tile belongs to account A.
      final tileA = find.text(
        '${pubkeyA.substring(0, 8)}…${pubkeyA.substring(pubkeyA.length - 6)}',
      );
      expect(tileA, findsOneWidget);

      await tester.tap(tileA);
      await tester.pumpAndSettle();

      expect(sessionUsecase.currentSession, isA<Auth>());
      expect(sessionUsecase.currentSession.pubkey, pubkeyA);
      expect(sessionUsecase.currentSession.pubkey, isNot(pubkeyB));
    });

    testWidgets('add account button invokes the callback', (tester) async {
      await setUpTwoAccounts();

      var addAccountTaps = 0;
      await tester.pumpWidget(
        AppLauncher.launchApp(
          tester: tester,
          child: AccountSwitcherPanel(onAddAccount: () => addAccountTaps++),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(addAccountTaps, 1);
    });
  });
}
