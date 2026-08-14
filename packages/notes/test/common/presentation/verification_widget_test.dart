import 'package:di_storage/di_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nostr/model/user_keys.dart';
import 'package:common/data/repo/key_tool_repository_impl.dart';
import 'package:nostr_notes/common/domain/model/session/session.dart';
import 'package:common/domain/repo/app_lifecycle_listener_repository.dart';
import 'package:nostr_notes/common/domain/repository/biometric_repository.dart';
import 'package:nostr_notes/common/domain/usecase/auth_usecase.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';
import 'package:nostr_notes/common/domain/usecase/verification_usecase.dart';
import 'package:nostr_notes/common/presentation/blur_widget/verification_widget.dart';
import 'package:rxdart/rxdart.dart';

import '../../tools/mocks/mock_accounts_repo.dart';
import '../../tools/mocks/mock_relays_list_repo.dart';
import '../../tools/mocks/mock_secure_storage.dart';
import '../../tools/some_moked_data.dart';

class _MockBiometricRepository extends Mock implements BiometricRepository {}

class _MockAppLifecycleListenerRepository
    implements AppLifecycleListenerRepository {
  @override
  late final PublishSubject<bool> isActiveStream = PublishSubject();

  @override
  Future<void> dispose() async => isActiveStream.close();
}

void main() {
  // VerificationBloc has two chained debounceTime(200ms):
  // 1. stream subscription listener
  // 2. ShowOverlayEvent / HideOverlayEvent handler
  // Total minimum: 400ms. Use 600ms for margin.
  const debounce = Duration(milliseconds: 600);
  const maxTimeout = Timeout(Duration(seconds: 10));

  late _MockBiometricRepository biometry;
  late _MockAppLifecycleListenerRepository lifecycle;
  late SessionUsecase sessionUsecase;
  late VerificationUsecase verificationUsecase;

  const unlockedSession = Unlocked(
    keys: UserKeys(
      publicKey: SomeMokedData.publicKey,
      privateKey: SomeMokedData.privateKey,
    ),
    pin: '1234',
  );

  AuthUsecase buildAuthUsecase() => AuthUsecase(
    secureStorage: MockSecureStorage(),
    sessionUsecase: sessionUsecase,
    keyToolRepository: const KeyToolRepositoryImpl(),
    relaysListRepo: MockRelaysListRepo(),
    accountsRepo: MockAccountsRepo(),
  );

  void bindVerificationUsecase() {
    DiStorage.shared.bind<VerificationUsecase>(
      () => verificationUsecase,
      module: null,
      lifeTime: const LifeTime.single(),
    );
  }

  setUp(() {
    biometry = _MockBiometricRepository();
    lifecycle = _MockAppLifecycleListenerRepository();
    sessionUsecase = SessionUsecase();

    verificationUsecase = VerificationUsecase(
      biometricRepository: biometry,
      appLifecycleListenerRepository: lifecycle,
      authUsecase: buildAuthUsecase(),
      maxInactiveDuration: Duration.zero,
    );

    bindVerificationUsecase();
  });

  tearDown(() async {
    DiStorage.shared.removeAll();
    await sessionUsecase.dispose();
  });

  Widget buildSubject({Widget child = const SizedBox.shrink()}) {
    return MaterialApp(home: VerificationWidget(child: child));
  }

  // Pumps buildSubject() and unmounts it again on tearDown — without an
  // explicit unmount, VerificationWidget's Overlay (and its OverlayEntry)
  // is never disposed, since flutter_test doesn't unmount a pumped tree on
  // its own at test end.
  Future<void> pumpSubject(
    WidgetTester tester, {
    Widget child = const SizedBox.shrink(),
  }) async {
    await tester.pumpWidget(buildSubject(child: child));
    addTearDown(() async {
      await tester.pumpWidget(Container());
      await tester.pump();
    });
  }

  group('overlay visibility', () {
    testWidgets('overlay not shown initially', (tester) async {
      await pumpSubject(tester);

      expect(find.byType(BackdropFilter), findsNothing);
    }, timeout: maxTimeout);

    testWidgets(
      'overlay appears when app goes to background (Unlocked session)',
      (tester) async {
        sessionUsecase.setSession(unlockedSession);
        await pumpSubject(tester);

        lifecycle.isActiveStream.add(false);
        await tester.pump(debounce);

        expect(find.byType(BackdropFilter), findsOneWidget);
      },
      timeout: maxTimeout,
    );

    testWidgets('overlay does not appear when session is not Unlocked', (
      tester,
    ) async {
      // session is Unauth by default
      await pumpSubject(tester);

      lifecycle.isActiveStream.add(false);
      await tester.pump(debounce);

      expect(find.byType(BackdropFilter), findsNothing);
    }, timeout: maxTimeout);

    testWidgets(
      'overlay is removed when app returns to foreground quickly',
      (tester) async {
        sessionUsecase.setSession(unlockedSession);
        // Rebuild with large maxInactiveDuration so quick return skips biometry
        DiStorage.shared.remove<VerificationUsecase>();
        verificationUsecase = VerificationUsecase(
          biometricRepository: biometry,
          appLifecycleListenerRepository: lifecycle,
          authUsecase: buildAuthUsecase(),
        );
        bindVerificationUsecase();

        await pumpSubject(tester);

        lifecycle.isActiveStream.add(false);
        await tester.pump(debounce);
        expect(find.byType(BackdropFilter), findsOneWidget);

        lifecycle.isActiveStream.add(true);
        await tester.pump(debounce);
        expect(find.byType(BackdropFilter), findsNothing);
      },
      timeout: maxTimeout,
    );

    testWidgets('overlay absorbs pointer events while shown', (tester) async {
      sessionUsecase.setSession(unlockedSession);
      var tapped = false;
      await pumpSubject(
        tester,
        child: GestureDetector(
          onTap: () => tapped = true,
          child: const SizedBox(width: 100, height: 100),
        ),
      );

      lifecycle.isActiveStream.add(false);
      await tester.pump(debounce);
      expect(find.byType(BackdropFilter), findsOneWidget);

      await tester.tapAt(const Offset(50, 50));
      expect(tapped, isFalse);
    }, timeout: maxTimeout);

    testWidgets('child is rendered', (tester) async {
      const key = Key('child_key');
      await pumpSubject(tester, child: const SizedBox(key: key));

      expect(find.byKey(key), findsOneWidget);
    }, timeout: maxTimeout);
  });
}
