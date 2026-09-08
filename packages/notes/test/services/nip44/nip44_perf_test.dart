@Tags(['perf'])
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_notes/services/nip44/nip44.dart';

/// Wall-clock measurements, kept out of the default run — see dart_test.yaml.
/// flutter_test's group()/test() take no `tags`, so the whole file carries the
/// annotation and only performance cases belong here.
void main() {
  const text =
      'Lorem ipsum dolor sit amet consectetur adipiscing elit. '
      'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.';
  const iterations = 5;
  group('Nip44 encryption/decryption performance', () {
    const Nip44 sut = Nip44();
    test('Nip44 encryption/decryption performance', () async {
      const privateKey =
          '49b3084ebe2d6a1c1c9f68be41c89593c7a1d0a80e23f259df341bfa8e5b5bd8';
      const publicKey =
          '5f23c86b8dd9a3a3fd020d5f3f87293ffcba7e66b23437a164ed41f67d75f7ee';

      final stopwatch = Stopwatch()..start();

      for (var i = 0; i < iterations; i++) {
        final Uint8List conversationKey = sut.deriveKeys(
          senderPrivateKey: privateKey,
          recipientPublicKey: publicKey,
        );

        final encrypted = await sut.encryptMessage(
          plaintext: '$text $i',
          conversationKey: conversationKey,
        );

        final decrypted = await sut.decryptMessage(
          payload: encrypted,
          conversationKey: conversationKey,
        );

        expect(decrypted, '$text $i');
      }

      stopwatch.stop();
      debugPrint(
        'Nip44 encryption/decryption of $iterations messages took: ${stopwatch.elapsedMilliseconds} ms',
      );

      expect(stopwatch.elapsedMilliseconds < 3000, true);
    });

    test('spec256k1', () async {
      const privateKey =
          '49b3084ebe2d6a1c1c9f68be41c89593c7a1d0a80e23f259df341bfa8e5b5bd8';
      const publicKey =
          '5f23c86b8dd9a3a3fd020d5f3f87293ffcba7e66b23437a164ed41f67d75f7ee';

      final stopwatch = Stopwatch()..start();

      for (var i = 0; i < iterations; i++) {
        final Uint8List conversationKey = sut.deriveKeys(
          senderPrivateKey: privateKey,
          recipientPublicKey: publicKey,
        );

        expect(conversationKey, isA<Uint8List>());
      }

      stopwatch.stop();
      debugPrint(
        'spec256k1 of $iterations took: ${stopwatch.elapsedMilliseconds} ms',
      );

      expect(stopwatch.elapsedMilliseconds < 300, true);
    });

    test(
      'Nip44 encryption/decryption performance with cached conversation key',
      () async {
        const privateKey =
            '49b3084ebe2d6a1c1c9f68be41c89593c7a1d0a80e23f259df341bfa8e5b5bd8';
        const publicKey =
            '5f23c86b8dd9a3a3fd020d5f3f87293ffcba7e66b23437a164ed41f67d75f7ee';

        final Uint8List conversationKey = sut.deriveKeys(
          senderPrivateKey: privateKey,
          recipientPublicKey: publicKey,
        );

        final stopwatch = Stopwatch()..start();

        for (var i = 0; i < iterations; i++) {
          final encrypted = await sut.encryptMessage(
            plaintext: '$text $i',
            conversationKey: conversationKey,
          );

          final decrypted = await sut.decryptMessage(
            payload: encrypted,
            conversationKey: conversationKey,
          );

          expect(decrypted, '$text $i');
        }

        stopwatch.stop();
        debugPrint(
          'Nip44 encryption/decryption of $iterations messages took: ${stopwatch.elapsedMilliseconds} ms',
        );

        expect(stopwatch.elapsedMilliseconds < 400, true);
      },
    );
  });
}
