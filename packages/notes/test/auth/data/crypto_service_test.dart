import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_notes/services/crypto_service/crypto_service.dart';
import 'package:nostr_notes/services/hex_to_bytes.dart';

void main() {
  final sut = CryptoService.create();

  group('Nip44 encryption/decryption performance', () {
    test('spec256k1', () async {
      const privateKey =
          '49b3084ebe2d6a1c1c9f68be41c89593c7a1d0a80e23f259df341bfa8e5b5bd8';
      const publicKey =
          '5f23c86b8dd9a3a3fd020d5f3f87293ffcba7e66b23437a164ed41f67d75f7ee';

      const iterations = 100;
      final stopwatch = Stopwatch()..start();

      for (var i = 0; i < iterations; i++) {
        final Uint8List conversationKey = await sut.spec256k1Async(
          senderPrivateKey: HexToBytes.hexToBytes(privateKey),
          recipientPublicKey: HexToBytes.hexToBytes(publicKey),
        );

        expect(conversationKey, isA<Uint8List>());
      }

      stopwatch.stop();
      debugPrint(
        'spec256k1 of $iterations took: ${stopwatch.elapsedMilliseconds} ms',
      );

      expect(stopwatch.elapsedMilliseconds < 300, true);

      // No ffi, no isolate - spec256k1 of 10000 took: 8642 ms
      // No ffi, isolate - spec256k1 of 10000 took: 9085 ms
      // ffi, no isolate - spec256k1 of 10000 took: 12675 ms
    });
  });
}
