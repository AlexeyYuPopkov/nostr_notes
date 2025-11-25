import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_notes/services/nip44/nip44.dart';

void main() {
  const text = 'Lorem ipsum dolor sit amet consectetur adipiscing elit. '
      'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.';
  group('Nip44', () {
    final Nip44 sut = const Nip44();
    test('Nip44 encryption and decryption', () async {
      const privateKey =
          '49b3084ebe2d6a1c1c9f68be41c89593c7a1d0a80e23f259df341bfa8e5b5bd8';
      const publicKey =
          '5f23c86b8dd9a3a3fd020d5f3f87293ffcba7e66b23437a164ed41f67d75f7ee';

      final Uint8List conversationKey = sut.deriveKeys(
        senderPrivateKey: privateKey,
        recipientPublicKey: publicKey,
      );

      final encrypted = await sut.encryptMessage(
        plaintext: text,
        conversationKey: conversationKey,
      );

      final decrypted = await sut.decryptMessage(
        payload: encrypted,
        conversationKey: conversationKey,
      );

      expect(encrypted != text, true);
      expect(decrypted, text);
    });

    // test('Nip44 + AES + cached conversation key', () async {
    //   const privateKey =
    //       '49b3084ebe2d6a1c1c9f68be41c89593c7a1d0a80e23f259df341bfa8e5b5bd8';
    //   const publicKey =
    //       '5f23c86b8dd9a3a3fd020d5f3f87293ffcba7e66b23437a164ed41f67d75f7ee';

    //   // Step 1: Compute Shared Secret
    //   final sharedSecret = Nip44.computeSharedSecret(privateKey, publicKey);

    //   // Step 2: Derive Conversation Key
    //   final conversationKey = Nip44.deriveConversationKey(sharedSecret);

    //   final encrypted = await Nip44.encryptMessage(
    //     plaintext: text,
    //     senderPrivateKey: privateKey,
    //     recipientPublicKey: publicKey,
    //     customConversationKey: conversationKey,
    //   );

    //   final decrypted = await Nip44.decryptMessage(
    //     payload: encrypted,
    //     recipientPrivateKey: privateKey,
    //     senderPublicKey: publicKey,
    //   );

    //   expect(encrypted != text, true);
    //   expect(decrypted == text, true);
    // });
  });

  group('Nip44 encryption/decryption performance', () {
    final Nip44 sut = const Nip44();
    test('Nip44 encryption/decryption performance', () async {
      const privateKey =
          '49b3084ebe2d6a1c1c9f68be41c89593c7a1d0a80e23f259df341bfa8e5b5bd8';
      const publicKey =
          '5f23c86b8dd9a3a3fd020d5f3f87293ffcba7e66b23437a164ed41f67d75f7ee';

      const iterations = 100;
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

      expect(stopwatch.elapsedMilliseconds < 2000, true);
    });

    test('Nip44 encryption/decryption performance with cached conversation key',
        () async {
      const privateKey =
          '49b3084ebe2d6a1c1c9f68be41c89593c7a1d0a80e23f259df341bfa8e5b5bd8';
      const publicKey =
          '5f23c86b8dd9a3a3fd020d5f3f87293ffcba7e66b23437a164ed41f67d75f7ee';

      // final sharedSecret = Nip44.computeSharedSecret(privateKey, publicKey);
      // final conversationKey = Nip44.deriveConversationKey(sharedSecret);

      final Uint8List conversationKey = sut.deriveKeys(
        senderPrivateKey: privateKey,
        recipientPublicKey: publicKey,
      );

      const iterations = 100;
      final stopwatch = Stopwatch()..start();

      for (var i = 0; i < iterations; i++) {
        final encrypted = await sut.encryptMessage(
          plaintext: '$text $i',
          conversationKey: conversationKey,
          // senderPrivateKey: privateKey,
          // recipientPublicKey: publicKey,
          // customConversationKey: conversationKey,
        );

        final decrypted = await sut.decryptMessage(
          payload: encrypted,
          conversationKey: conversationKey,
          // recipientPrivateKey: privateKey,
          // senderPublicKey: publicKey,
          // customConversationKey: conversationKey,
        );

        expect(decrypted, '$text $i');
      }

      stopwatch.stop();
      debugPrint(
        'Nip44 encryption/decryption of $iterations messages took: ${stopwatch.elapsedMilliseconds} ms',
      );

      expect(stopwatch.elapsedMilliseconds < 300, true);
    });
  });
}
