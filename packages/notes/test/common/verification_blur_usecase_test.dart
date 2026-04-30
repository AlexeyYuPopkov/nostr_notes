import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nostr_notes/common/data/key_tool_repository_impl.dart';
import 'package:nostr_notes/common/domain/model/session/session.dart';
import 'package:nostr_notes/common/domain/model/session/user_keys.dart';
import 'package:nostr_notes/common/domain/repository/app_lifecycle_listener_repository.dart';
import 'package:nostr_notes/common/domain/repository/biometric_repository.dart';
import 'package:nostr_notes/common/domain/usecase/auth_usecase.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';
import 'package:nostr_notes/common/domain/usecase/verification_usecase.dart';

import 'package:rxdart/rxdart.dart';

import '../tools/mocks/mock_relays_list_repo.dart';
import '../tools/mocks/mock_secure_storage.dart';
import '../tools/some_moked_data.dart';

class MockBiometricRepository extends Mock implements BiometricRepository {}

class MockAppLifecycleListenerRepository
    implements AppLifecycleListenerRepository {
  @override
  late final PublishSubject<bool> isActiveStream = PublishSubject();

  @override
  Future<void> dispose() async {
    isActiveStream.close();
  }
}

void main() {
  const maxTimeout = Timeout(Duration(seconds: 10));

  late BiometricRepository biometry;
  late MockAppLifecycleListenerRepository lifecycle;
  late AuthUsecase authUsecase;

  late MockSecureStorage secureStorage;
  late MockRelaysListRepo relaysListRepo;
  late SessionUsecase sessionUsecase;
  late KeyToolRepositoryImpl keyToolRepository;

  late VerificationUsecase sut;

  const allow = Verification.allow();
  const deny = Verification.deny();
  const processing = Verification.processing();
  const biometryRequest = BiometricRepositoryRequest(
    localizedReason: 'Unlock application',
  );

  const unlockedSession = Unlocked(
    keys: UserKeys(
      publicKey: SomeMokedData.publicKey,
      privateKey: SomeMokedData.privateKey,
    ),
    pin: '1234',
  );

  void buildSut({
    Duration maxInactiveDuration =
        VerificationUsecase.defaultMaxInactiveDuration,
  }) {
    sut = VerificationUsecase(
      biometricRepository: biometry,
      appLifecycleListenerRepository: lifecycle,
      authUsecase: authUsecase,
      maxInactiveDuration: maxInactiveDuration,
    );
  }

  setUp(() {
    biometry = MockBiometricRepository();
    lifecycle = MockAppLifecycleListenerRepository();

    secureStorage = MockSecureStorage();
    relaysListRepo = MockRelaysListRepo();
    sessionUsecase = SessionUsecase();
    keyToolRepository = const KeyToolRepositoryImpl();

    authUsecase = AuthUsecase(
      secureStorage: secureStorage,
      sessionUsecase: sessionUsecase,
      keyToolRepository: keyToolRepository,
      relaysListRepo: relaysListRepo,
    );
    buildSut();
  });

  tearDown(() async {
    await sut.dispose();
    await sessionUsecase.dispose();
  });

  group('when session is not unlocked (Unauth)', () {
    test('going to background emits Allow', () async {
      final stream = sut.createStream(biometryRequest: biometryRequest);
      final emitted = <Verification>[];
      final sub = stream.listen(emitted.add);

      lifecycle.isActiveStream.add(false);
      await pumpEventQueue();

      expect(emitted, [allow]);
      await sub.cancel();
    }, timeout: maxTimeout);
  });

  group('when session is Unlocked', () {
    setUp(() {
      sessionUsecase.setSession(unlockedSession);
    });

    test('going to background emits Deny', () async {
      final stream = sut.createStream(biometryRequest: biometryRequest);
      final emitted = <Verification>[];
      final sub = stream.listen(emitted.add);

      lifecycle.isActiveStream.add(false);
      await pumpEventQueue();

      expect(emitted, [isA<Deny>()]);
      await sub.cancel();
    }, timeout: maxTimeout);

    test(
      'returning quickly (within maxInactiveDuration) emits Allow without biometry',
      () async {
        final stream = sut.createStream(biometryRequest: biometryRequest);
        final emitted = <Verification>[];
        final sub = stream.listen(emitted.add);

        lifecycle.isActiveStream.add(false);
        lifecycle.isActiveStream.add(true);
        await pumpEventQueue();

        expect(emitted, [isA<Deny>(), allow]);
        verifyNever(() => biometry.execute(biometryRequest));
        await sub.cancel();
      },
      timeout: maxTimeout,
    );

    test('duplicate background events are deduplicated', () async {
      final stream = sut.createStream(biometryRequest: biometryRequest);
      final emitted = <Verification>[];
      final sub = stream.listen(emitted.add);

      lifecycle.isActiveStream.add(false);
      lifecycle.isActiveStream.add(false); // duplicate — filtered by distinct
      await pumpEventQueue();

      expect(emitted, [isA<Deny>()]);
      await sub.cancel();
    }, timeout: maxTimeout);
  });

  group('when session is Unlocked and maxInactiveDuration is zero', () {
    setUp(() {
      sessionUsecase.setSession(unlockedSession);
      buildSut(maxInactiveDuration: Duration.zero);
    });

    test(
      'returning after inactivity emits Processing then Allow when biometry succeeds',
      () async {
        when(
          () => biometry.execute(biometryRequest),
        ).thenAnswer((_) async => true);

        final stream = sut.createStream(biometryRequest: biometryRequest);
        final emitted = <Verification>[];
        final sub = stream.listen(emitted.add);

        lifecycle.isActiveStream.add(false);
        await pumpEventQueue();
        expect(emitted, [deny]);

        // slight delay ensures _deniedAt < DateTime.now() with Duration.zero
        await Future.delayed(const Duration(milliseconds: 1));

        lifecycle.isActiveStream.add(true);
        await pumpEventQueue();

        expect(emitted, [deny, processing, allow]);
        await sub.cancel();
      },
      timeout: maxTimeout,
    );

    test(
      'biometry failure emits Deny and restores session to Unauth',
      () async {
        when(
          () => biometry.execute(biometryRequest),
        ).thenAnswer((_) async => false);

        final stream = sut.createStream(biometryRequest: biometryRequest);
        final emitted = <Verification>[];
        final sub = stream.listen(emitted.add);

        lifecycle.isActiveStream.add(false);
        await pumpEventQueue();
        expect(emitted, [deny]);

        await Future.delayed(const Duration(milliseconds: 1));

        // await Future.delayed(VerificationUsecase.defaultMaxInactiveDuration);

        lifecycle.isActiveStream.add(true);
        await pumpEventQueue();

        expect(emitted, [deny, processing, deny]);
        // secureStorage is empty → restore() sets Unauth
        expect(sessionUsecase.currentSession, isA<Unauth>());
        await sub.cancel();
      },
      timeout: maxTimeout,
    );
  });
}
