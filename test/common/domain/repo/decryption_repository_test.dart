import 'package:flutter_test/flutter_test.dart';

import 'package:nostr_notes/common/data/decryption_repository_impl.dart';
import 'package:nostr_notes/common/domain/repository/decryption_repository.dart';

void main() {
  late DecryptionRepository sut;

  setUp(() {
    sut = const DecryptionRepositoryImpl();
  });

  group('DecryptionRepository', () {
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
}
