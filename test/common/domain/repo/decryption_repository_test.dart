import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nostr_notes/common/data/decryption_repository_impl.dart';
import 'package:nostr_notes/common/domain/repository/decryption_repository.dart';

void main() {
  group('DecryptionRepository', () {
    late DecryptionRepository sut;

    setUp(() {
      sut = const DecryptionRepositoryImpl();
    });
    test('encrypt & decrypted', () async {
      const plaintext = 'Hello, World!';
      const password = '1234';

      final encrypted = await sut.encrypt(
        plaintext: plaintext,
        password: password,
      );

      final decrypted = await sut.decrypt(
        ciphertext: encrypted,
        password: password,
      );
      expect(encrypted, isA<String>());
      expect(decrypted, isA<String>());
      expect(encrypted.isNotEmpty, true);
      expect(decrypted.isNotEmpty, true);
      expect(encrypted != plaintext, true);
      expect(decrypted == plaintext, true);
    });

    test('throws wrong passwird', () async {
      const plaintext = 'Hello, World!';

      final encrypted = await sut.encrypt(
        plaintext: plaintext,
        password: '4321',
      );

      final result = sut.decrypt(
        ciphertext: encrypted,
        password: '1234',
      );

      expect(encrypted, isA<String>());
      expect(encrypted.isNotEmpty, true);

      expect(
        () async => await result,
        throwsA(isA<DecryptionRepositoryHmacException>()),
      );
    });
  });

  group('SessionUsecase performance', () {
    late DecryptionRepository sut;

    setUp(() {
      sut = const DecryptionRepositoryImpl();
    });

    test('encryption/decryption performance', () async {
      const iterations = 2;
      final stopwatch = Stopwatch()..start();

      for (var i = 0; i < iterations; i++) {
        final initial =
            'Lorem ipsum dolor sit amet consectetur adipiscing elit. '
            'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.'
            ' $i';
        const password = 'qwertyui';

        final encrypted = await sut.encrypt(
          plaintext: initial,
          password: password,
        );

        final decrypted = await sut.decrypt(
          ciphertext: encrypted,
          password: password,
        );

        expect(decrypted, initial);
      }

      stopwatch.stop();
      debugPrint(
        'AES encryption/decryption of $iterations messages took: ${stopwatch.elapsedMilliseconds} ms',
      );

      // expect(stopwatch.elapsedMilliseconds < 4000, true);
    });
  });
}
