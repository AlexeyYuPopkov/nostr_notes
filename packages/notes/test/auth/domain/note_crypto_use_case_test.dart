import 'dart:developer';

import 'package:flutter_test/flutter_test.dart';
import 'package:nostr/model/user_keys.dart';
import 'package:nostr_notes/auth/domain/model/label.dart';
import 'package:nostr_notes/auth/domain/model/note.dart';
import 'package:nostr_notes/auth/domain/model/pin_kdf.dart';
import 'package:nostr_notes/auth/domain/usecase/note_crypto_use_case.dart';
import 'package:nostr_notes/common/domain/model/session/session.dart';
import 'package:nostr_notes/common/domain/usecase/session_usecase.dart';
import 'package:nostr_notes/services/crypto_service/crypto_service.dart';

void main() {
  const text =
      'Lorem ipsum dolor sit amet consectetur adipiscing elit. '
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
    late CryptoService cryptoService;
    late ExtraDerivation extraDerivation;

    setUp(() async {
      sessionUsecase = SessionUsecase();

      cryptoService = CryptoService.create();
      extraDerivation = ExtraDerivation(
        cryptoService: cryptoService,
        sessionUsecase: sessionUsecase,
      );

      await cryptoService.init();

      sut = NoteCryptoUseCase(
        cryptoService: cryptoService,
        sessionUsecase: sessionUsecase,
        extraDerivation: extraDerivation,
      );
    });

    tearDown(() => sessionUsecase.dispose());

    test('encryption and decryption Note. With Pin', () async {
      sessionUsecase.setSession(
        const Session.unlocked(
          keys: UserKeys(privateKey: privateKey, publicKey: publicKey),
          pin: pin,
        ),
      );

      final initialNote = Note(
        eventId: 'eventId',
        dTag: 'dTag',
        content: text,
        summary: summary,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        labels: [Label.from('work'), Label.from('journal')],
      );

      final encrypted = await sut.encryptNote(initialNote);

      final decrypted = await sut.decryptNote(encrypted);

      // encryptNote stamps the note with the current KDF — that upgrade is
      // exactly how an old note migrates, so it survives the round trip.
      expect(decrypted, initialNote.copyWith(kdf: PinKdf.current));
    });

    test('a note written before PBKDF2 still decrypts', () async {
      sessionUsecase.setSession(
        const Session.unlocked(
          keys: UserKeys(privateKey: privateKey, publicKey: publicKey),
          pin: pin,
        ),
      );

      // Built the way the app used to build it, so this is genuine ciphertext
      // from before the migration rather than a relabelled new note.
      final legacyKey = await cryptoService.deriveKeysAsync(
        senderPrivateKey: privateKey,
        recipientPublicKey: publicKey,
        extraDerivation: extraDerivation.execute(pin, kdf: PinKdf.legacySha256),
      );
      final onRelay = Note(
        eventId: 'eventId',
        dTag: 'dTag',
        content: await cryptoService.encryptNip44(
          plaintext: text,
          conversationKey: legacyKey,
        ),
        summary: await cryptoService.encryptNip44(
          plaintext: summary,
          conversationKey: legacyKey,
        ),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        kdf: PinKdf.legacySha256,
      );

      final decrypted = await sut.decryptNote(onRelay);

      expect(decrypted.content, text);
      expect(decrypted.summary, summary);
    });

    test('the legacy key derivation is frozen', () async {
      sessionUsecase.setSession(
        const Session.unlocked(
          keys: UserKeys(privateKey: privateKey, publicKey: publicKey),
          pin: pin,
        ),
      );

      final key = await cryptoService.deriveKeysAsync(
        senderPrivateKey: privateKey,
        recipientPublicKey: publicKey,
        extraDerivation: extraDerivation.execute(pin, kdf: PinKdf.legacySha256),
      );

      expect(
        key.map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
        '13092e838484e58d6bcd66001c0bdca0b9bed5a318f0c0efc450baaac2b5ee60',
        reason:
            'Notes already on relays were encrypted with this exact key. '
            'If this value has to change, they can no longer be read — the '
            'legacy branch is a format, not an implementation detail.',
      );
    });

    test('the two KDFs derive different keys from the same PIN', () async {
      sessionUsecase.setSession(
        const Session.unlocked(
          keys: UserKeys(privateKey: privateKey, publicKey: publicKey),
          pin: pin,
        ),
      );

      Future<List<int>> keyFor(PinKdf kdf) => cryptoService.deriveKeysAsync(
        senderPrivateKey: privateKey,
        recipientPublicKey: publicKey,
        extraDerivation: extraDerivation.execute(pin, kdf: kdf),
      );

      expect(
        await keyFor(PinKdf.legacySha256),
        isNot(await keyFor(PinKdf.pbkdf2)),
        reason:
            'without this the migration would be a no-op and the legacy test '
            'above would pass for the wrong reason',
      );
    });

    test('encrypt Note and decryption Note summary only. With Pin', () async {
      sessionUsecase.setSession(
        const Session.unlocked(
          keys: UserKeys(privateKey: privateKey, publicKey: publicKey),
          pin: pin,
        ),
      );

      final initialNote = Note(
        eventId: 'eventId',
        dTag: 'dTag',
        content: text,
        summary: summary,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        labels: [Label.from('work'), Label.from('journal')],
      );

      final encrypted = await sut.encryptNote(initialNote);

      final decrypted = await sut.decryptSummary(encrypted);

      expect(encrypted.summary == decrypted.summary, false);
    });

    test('encryption and decryption Note. Without Pin', () async {
      sessionUsecase.setSession(
        const Session.unlocked(
          keys: UserKeys(privateKey: privateKey, publicKey: publicKey),
          pin: '',
        ),
      );

      final initialNote = Note(
        eventId: 'eventId',
        dTag: 'dTag',
        content: text,
        summary: summary,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        labels: [Label.from('work'), Label.from('journal')],
      );

      final encrypted = await sut.encryptNote(initialNote);

      final decrypted = await sut.decryptNote(encrypted);

      // encryptNote stamps the note with the current KDF — that upgrade is
      // exactly how an old note migrates, so it survives the round trip.
      // No PIN took part, and the note records that rather than staying
      // silent about it.
      expect(decrypted, initialNote.copyWith(kdf: PinKdf.none));
    });

    test(
      'encrypt Note and decryption Note summary only. Without Pin',
      () async {
        sessionUsecase.setSession(
          const Session.unlocked(
            keys: UserKeys(privateKey: privateKey, publicKey: publicKey),
            pin: '',
          ),
        );

        final initialNote = Note(
          eventId: 'eventId',
          dTag: 'dTag',
          content: text,
          summary: summary,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          labels: [Label.from('work'), Label.from('journal')],
        );

        final encrypted = await sut.encryptNote(initialNote);

        final decrypted = await sut.decryptSummary(encrypted);

        expect(encrypted.summary == decrypted.summary, false);
      },
    );
  });

  group('SessionUsecase performance', () {
    late SessionUsecase sessionUsecase;
    late NoteCryptoUseCase sut;

    setUp(() async {
      sessionUsecase = SessionUsecase();
      final cryptoService = CryptoService.create();
      final extraDerivation = ExtraDerivation(
        cryptoService: cryptoService,
        sessionUsecase: sessionUsecase,
      );

      await cryptoService.init();

      sut = NoteCryptoUseCase(
        cryptoService: cryptoService,
        sessionUsecase: sessionUsecase,
        extraDerivation: extraDerivation,
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
          keys: UserKeys(privateKey: privateKey, publicKey: publicKey),
          pin: pin,
        ),
      );

      for (var i = 0; i < iterations; i++) {
        final initialNote = Note(
          eventId: 'eventId',
          dTag: 'dTag',
          content: '$text $i',
          summary: '$summary $i',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final encrypted = await sut.encryptNote(initialNote);

        final decrypted = await sut.decryptNote(encrypted);

        expect(
          decrypted,
          initialNote.copyWith(kdf: PinKdf.current),
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
