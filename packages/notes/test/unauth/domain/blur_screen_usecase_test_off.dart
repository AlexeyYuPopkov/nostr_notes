// import 'package:common/domain/repo/secure_storage.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mocktail/mocktail.dart';
// import 'package:fake_async/fake_async.dart';
// import 'package:nostr_notes/unauth/domain/blur_screen_usecase.dart';
// import 'package:nostr_notes/common/domain/usecase/auth_usecase.dart';
// import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';
// import 'package:common/domain/repo/relays_list_repo.dart';
// import 'package:common/data/repo/key_tool_repository_impl.dart';
// import 'package:nostr_notes/core/tools/now.dart';

// class MockSecureStorage extends Mock implements SecureStorage {}

// class MockRelaysListRepo extends Mock implements RelaysListRepo {}

// void main() {
//   late MockSecureStorage secureStorage;
//   late MockRelaysListRepo relaysListRepo;
//   late SessionUsecase sessionUsecase;
//   late KeyToolRepositoryImpl keyToolRepository;
//   late AuthUsecase authUsecase;
//   late DateTime now;
//   late Now nowProvider;
//   late BlurScreenUsecase sut;

//   setUp(() {
//     secureStorage = MockSecureStorage();
//     relaysListRepo = MockRelaysListRepo();
//     sessionUsecase = SessionUsecase();
//     keyToolRepository = const KeyToolRepositoryImpl();
//     authUsecase = AuthUsecase(
//       secureStorage: secureStorage,
//       sessionUsecase: sessionUsecase,
//       keyToolRepository: keyToolRepository,
//       relaysListRepo: relaysListRepo,
//     );
//     now = DateTime(2024, 1, 1, 12, 0, 0);
//     nowProvider = NowMock(() => now);
//     sut = BlurScreenUsecase(authUsecase: authUsecase, now: nowProvider);
//   });

//   test('onForeground after validTill -> restore & locked', () async {
//     fakeAsync((async) {
//       when(
//         () => secureStorage.getValue(key: any(named: 'key')),
//       ).thenAnswer((_) async => '00' * 32);
//       sut.onBackground();
//       async.elapse(const Duration(milliseconds: 1500));
//       expect(sut.currentState, BlurScreenState.blured);
//       now = now.add(
//         BlurScreenUsecase.validDuration + const Duration(seconds: 1),
//       );
//       sut.onForeground();
//       expect(sut.currentState, BlurScreenState.locked);
//       verify(() => secureStorage.getValue(key: any(named: 'key'))).called(1);
//     });
//   });

//   test('onForeground after validTill -> restore & unlocked', () async {
//     fakeAsync((async) {
//       when(
//         () => secureStorage.getValue(key: any(named: 'key')),
//       ).thenAnswer((_) async => '00' * 32);
//       sut.onBackground();
//       async.elapse(const Duration(milliseconds: 1500));
//       expect(sut.currentState, BlurScreenState.blured);
//       now = now.add(
//         BlurScreenUsecase.validDuration - const Duration(seconds: 1),
//       );
//       sut.onForeground();
//       expect(sut.currentState, BlurScreenState.unlocked);
//       verifyNever(() => secureStorage.getValue(key: any(named: 'key')));
//     });
//   });
// }

// class NowMock extends Now {
//   final DateTime Function() _now;
//   const NowMock(this._now);
//   @override
//   DateTime now() => _now();
// }
