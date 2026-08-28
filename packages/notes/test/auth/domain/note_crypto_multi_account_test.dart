import 'package:flutter_test/flutter_test.dart';
import 'package:nostr/model/user_keys.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/auth/domain/model/pin_kdf.dart';
import 'package:nostr_notes/auth/domain/usecase/note_crypto_use_case.dart';
import 'package:nostr_notes/common/domain/model/session/session.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';
import 'package:nostr_notes/services/crypto_service/crypto_service.dart';

/// Both key pairs are real secp256k1 pairs; the values themselves don't
/// matter, only that the two accounts derive different key material.
const _accountA = UserKeys(
  privateKey:
      '49b3084ebe2d6a1c1c9f68be41c89593c7a1d0a80e23f259df341bfa8e5b5bd8',
  publicKey: '5f23c86b8dd9a3a3fd020d5f3f87293ffcba7e66b23437a164ed41f67d75f7ee',
);
const _accountB = UserKeys(
  privateKey:
      'd511ca0405176c93f5412c13b2f915b753ad5625c0db29fdf42a9cd2e66fa1ce',
  publicKey: '8c78952169177d4fba467bee54029da5877ef4ffdaf10192baa74044a914df8f',
);

void main() {
  group('NoteCryptoUseCase across accounts', () {
    late SessionUsecase sessionUsecase;
    late NoteCryptoUseCase sut;

    setUp(() async {
      sessionUsecase = SessionUsecase();
      final cryptoService = CryptoService.create();
      await cryptoService.init();

      // One instance of each, as the DI scope binds them: the caches inside
      // outlive any single account, which is what makes switching risky.
      sut = NoteCryptoUseCase(
        cryptoService: cryptoService,
        sessionUsecase: sessionUsecase,
        extraDerivation: ExtraDerivation(
          cryptoService: cryptoService,
          sessionUsecase: sessionUsecase,
        ),
      );
    });

    tearDown(() => sessionUsecase.dispose());

    Note noteWith(String content) => Note(
      eventId: 'eventId',
      dTag: 'dTag',
      content: content,
      summary: 'summary',
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

    void switchTo(UserKeys keys, String pin) =>
        sessionUsecase.setSession(Unlocked(keys: keys, pin: pin));

    test('a note survives switching to another account and back', () async {
      switchTo(_accountA, '1234');
      final encryptedForA = await sut.encryptNote(noteWith('note of A'));

      switchTo(_accountB, '5678');
      final encryptedForB = await sut.encryptNote(noteWith('note of B'));
      expect((await sut.decryptNote(encryptedForB)).content, 'note of B');

      // A fresh Unlocked for the same account — this is what account
      // switching produces, and it must not hand back B's cached key.
      switchTo(_accountA, '1234');
      expect((await sut.decryptNote(encryptedForA)).content, 'note of A');
    });

    test('the same PIN on two accounts derives different keys', () async {
      switchTo(_accountA, '1234');
      final encryptedForA = await sut.encryptNote(noteWith('note of A'));

      switchTo(_accountB, '1234');

      await expectLater(
        sut.decryptNote(encryptedForA),
        throwsA(anything),
        reason:
            'the salt is derived from the account key material, so an equal '
            'PIN on a different account must not open the note',
      );
    });

    test('an account with no PIN round-trips and writes no KDF tag', () async {
      switchTo(_accountA, '');

      final encrypted = await sut.encryptNote(noteWith('no pin here'));

      expect(encrypted.kdf, PinKdf.legacySha256);
      expect((await sut.decryptNote(encrypted)).content, 'no pin here');
    });
  });
}
