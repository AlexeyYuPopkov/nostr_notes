import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_notes/services/key_tool/nip04_service.dart';

void main() {
  const text = 'Lorem ipsum dolor sit amet consectetur adipiscing elit. '
      'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.';

  const privateKey =
      '49b3084ebe2d6a1c1c9f68be41c89593c7a1d0a80e23f259df341bfa8e5b5bd8';
  const publicKey =
      '5f23c86b8dd9a3a3fd020d5f3f87293ffcba7e66b23437a164ed41f67d75f7ee';

  const sut = Nip04Service();

  group('Nip04Service', () {
    test('Nip04 encryption and decryption', () {
      const message = text;

      final encrypted = sut.encryptNip04(
        content: message,
        peerPubkey: publicKey,
        privateKey: privateKey,
      );

      final decrypted = sut.decryptNip04(
        content: encrypted,
        peerPubkey: publicKey,
        privateKey: privateKey,
      );

      expect(encrypted != message, true);
      expect(decrypted, message);
    });
  });

  group('Nip04Service - performance', () {
    test('Nip04 encryption/decryption with different message', () {
      const privateKey =
          '49b3084ebe2d6a1c1c9f68be41c89593c7a1d0a80e23f259df341bfa8e5b5bd8';
      const publicKey =
          '5f23c86b8dd9a3a3fd020d5f3f87293ffcba7e66b23437a164ed41f67d75f7ee';

      const iterations = 100;
      final stopwatch = Stopwatch()..start();

      for (var i = 0; i < iterations; i++) {
        final encrypted = sut.encryptNip04(
          content: '$text $i',
          privateKey: privateKey,
          peerPubkey: publicKey,
        );

        final decrypted = sut.decryptNip04(
          content: encrypted,
          privateKey: privateKey,
          peerPubkey: publicKey,
        );

        expect(decrypted, '$text $i');
      }

      stopwatch.stop();
      debugPrint(
        'Nip04 encryption/decryption of $iterations messages took: ${stopwatch.elapsedMilliseconds} ms',
      );

      expect(stopwatch.elapsedMilliseconds < 6000, true);
    });
  });
}
