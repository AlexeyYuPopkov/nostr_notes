import 'dart:developer';

import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/auth/domain/usecase/note_crypto_use_case.dart';
import 'package:nostr_notes/common/domain/model/session/session.dart';
import 'package:nostr_notes/common/domain/model/session/user_keys.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';
import 'package:nostr_notes/services/crypto_service/crypto_service.dart';

void main() {
  const text = 'Lorem ipsum dolor sit amet consectetur adipiscing elit. '
      'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.';
  const summary = 'Summary of the note';

  const pin = 'qwertyui';
  const privateKey =
      '49b3084ebe2d6a1c1c9f68be41c89593c7a1d0a80e23f259df341bfa8e5b5bd8';
  const publicKey =
      '5f23c86b8dd9a3a3fd020d5f3f87293ffcba7e66b23437a164ed41f67d75f7ee';

  group('NoteCryptoUseCase', () {
    late SessionUsecase sessionUsecase;
    late NoteCryptoUseCase sut;

    setUp(() async {
      sessionUsecase = SessionUsecase();

      final cryptoService = CryptoService.create();

      await cryptoService.init();

      sut = NoteCryptoUseCase(
        cryptoService: cryptoService,
        sessionUsecase: sessionUsecase,
      );
    });

    tearDown(() => sessionUsecase.dispose());

    test('encryption and decryption Note. With Pin', () async {
      sessionUsecase.setSession(
        const Session.unlocked(
          keys: UserKeys(
            privateKey: privateKey,
            publicKey: publicKey,
          ),
          pin: pin,
        ),
      );

      final initialNote = Note(
        dTag: 'dTag',
        content: text,
        summary: summary,
        createdAt: DateTime.now(),
      );

      final encrypted = await sut.encryptNote(initialNote);

      final decrypted = await sut.decryptNote(encrypted);

      expect(decrypted == initialNote, true);
    });

    test('encrypt Note and decryption Note summary only. With Pin', () async {
      sessionUsecase.setSession(
        const Session.unlocked(
          keys: UserKeys(
            privateKey: privateKey,
            publicKey: publicKey,
          ),
          pin: pin,
        ),
      );

      final initialNote = Note(
        dTag: 'dTag',
        content: text,
        summary: summary,
        createdAt: DateTime.now(),
      );

      final encrypted = await sut.encryptNote(initialNote);

      final decrypted = await sut.decryptSummary(encrypted);

      expect(encrypted.summary == decrypted.summary, false);
    });

    test('encryption and decryption Note. Without Pin', () async {
      sessionUsecase.setSession(
        const Session.unlocked(
          keys: UserKeys(
            privateKey: privateKey,
            publicKey: publicKey,
          ),
          pin: '',
        ),
      );

      final initialNote = Note(
        dTag: 'dTag',
        content: text,
        summary: summary,
        createdAt: DateTime.now(),
      );

      final encrypted = await sut.encryptNote(initialNote);

      final decrypted = await sut.decryptNote(encrypted);

      expect(decrypted == initialNote, true);
    });

    test('encrypt Note and decryption Note summary only. Without Pin',
        () async {
      sessionUsecase.setSession(
        const Session.unlocked(
          keys: UserKeys(
            privateKey: privateKey,
            publicKey: publicKey,
          ),
          pin: '',
        ),
      );

      final initialNote = Note(
        dTag: 'dTag',
        content: text,
        summary: summary,
        createdAt: DateTime.now(),
      );

      final encrypted = await sut.encryptNote(initialNote);

      final decrypted = await sut.decryptSummary(encrypted);

      expect(encrypted.summary == decrypted.summary, false);
    });
  });

  group('SessionUsecase performance', () {
    late SessionUsecase sessionUsecase;
    late NoteCryptoUseCase sut;

    setUp(() async {
      sessionUsecase = SessionUsecase();
      final cryptoService = CryptoService.create();

      await cryptoService.init();

      sut = NoteCryptoUseCase(
        cryptoService: cryptoService,
        sessionUsecase: sessionUsecase,
      );
    });

    tearDown(() => sessionUsecase.dispose());

    test('encryption/decryption performance', () async {
      const privateKey =
          '49b3084ebe2d6a1c1c9f68be41c89593c7a1d0a80e23f259df341bfa8e5b5bd8';
      const publicKey =
          '5f23c86b8dd9a3a3fd020d5f3f87293ffcba7e66b23437a164ed41f67d75f7ee';

      const pin = 'qwertyui';

      const iterations = 100;
      final stopwatch = Stopwatch()..start();

      sessionUsecase.setSession(
        const Session.unlocked(
          keys: UserKeys(
            privateKey: privateKey,
            publicKey: publicKey,
          ),
          pin: pin,
        ),
      );

      for (var i = 0; i < iterations; i++) {
        final initialNote = Note(
          dTag: 'dTag',
          content: '$text $i',
          summary: '$summary $i',
          createdAt: DateTime.now(),
        );

        final encrypted = await sut.encryptNote(initialNote);

        final decrypted = await sut.decryptNote(encrypted);

        expect(
          decrypted == initialNote,
          true,
          reason: 'Decrypted note does not match initial note',
        );
      }

      stopwatch.stop();
      log(
        'Nip44 encryption/decryption of $iterations messages took: ${stopwatch.elapsedMilliseconds} ms',
      );

      expect(stopwatch.elapsedMilliseconds < 1000, true);
    });
  });
}
