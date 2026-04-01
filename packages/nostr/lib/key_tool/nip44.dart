// import 'dart:convert';
// import 'dart:math';
// import 'dart:math';
// import 'package:cryptography/cryptography.dart' as cryptography;
// import 'package:pointycastle/export.dart';

// import 'package:flutter/foundation.dart';

// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:cryptography/cryptography.dart';

// /// NIP-44 symmetric encryption using XChaCha20-Poly1305
// class Nip441 {
//   final Cipher cipher = Cipher.xChaCha20Poly1305();
//   // xchacha20Poly1305Aead();

//   /// Encrypt message with shared key
//   Future<String> encrypt(String message, List<int> sharedKey) async {
//     final nonce = cipher.newNonce();

//     final secretBox = await cipher.encrypt(
//       utf8.encode(message),
//       secretKey: SecretKey(sharedKey),
//       nonce: nonce,
//     );

//     final combined = Uint8List.fromList(nonce + secretBox.cipherText + secretBox.mac.bytes);
//     return base64.encode(combined);
//   }

//   /// Decrypt message with shared key
//   Future<String> decrypt(String base64Payload, List<int> sharedKey) async {
//     final data = base64.decode(base64Payload);

//     final nonce = data.sublist(0, 24); // XChaCha20 nonce is 24 bytes
//     final cipherText = data.sublist(24, data.length - 16); // subtract 16-byte tag
//     final mac = Mac(data.sublist(data.length - 16));

//     final secretBox = SecretBox(cipherText, nonce: nonce, mac: mac);

//     final decrypted = await cipher.decrypt(
//       secretBox,
//       secretKey: SecretKey(sharedKey),
//     );

//     return utf8.decode(decrypted);
//   }
// }

// final class Nip44 {
//   static final _digest = SHA256Digest();
//   static const _hmacBlockSize = 64;
//   const Nip44();

//   static Future<String> decrypt(
//     String payload,
//     Uint8List conversationKey,
//   ) async {
//     final payloadData = decodePayload(payload);
//     final keys = getMessageKeys(conversationKey, payloadData['nonce']!);
//     final calculatedMac = hmacAad(
//       keys['hmac_key']!,
//       payloadData['ciphertext']!,
//       payloadData['nonce']!,
//     );
//     if (!listEquals(calculatedMac, payloadData['mac'])) {
//       throw Exception('Invalid MAC');
//     }
//     final padded = await chacha20Decrypt(
//       keys['chacha_key']!,
//       keys['chacha_nonce']!,
//       payloadData['ciphertext']!,
//     );
//     return unpad(padded);
//   }

//   static Map<String, Uint8List> decodePayload(String payload) {
//     if (payload.length < 132 || payload.length > 87472) {
//       throw Exception('Invalid payload length: ${payload.length}');
//     }
//     if (payload.startsWith('#')) {
//       throw Exception('Unknown encryption version');
//     }

//     Uint8List data;
//     try {
//       data = base64Decode(payload);
//     } catch (e) {
//       throw Exception('Invalid base64: $e');
//     }

//     if (data.length < 99 || data.length > 65603) {
//       throw Exception('Invalid data length: ${data.length}');
//     }

//     final version = data[0];
//     if (version != 2) {
//       throw Exception('Unknown encryption version $version');
//     }

//     return {
//       'nonce': data.sublist(1, 33),
//       'ciphertext': data.sublist(33, data.length - 32),
//       'mac': data.sublist(data.length - 32),
//     };
//   }

//   static Map<String, Uint8List> getMessageKeys(
//     Uint8List conversationKey,
//     Uint8List nonce,
//   ) {
//     assert(conversationKey.length == 32, 'Invalid conversation key');
//     assert(nonce.length == 32, 'Invalid nonce');

//     final keys = hkdfExpand(conversationKey, nonce, 76);

//     return {
//       'chacha_key': keys.sublist(0, 32),
//       'chacha_nonce': keys.sublist(32, 44),
//       'hmac_key': keys.sublist(44, 76),
//     };
//   }

//   static Uint8List hkdfExpand(Uint8List prk, Uint8List info, int outputLength) {
//     final hmac = HMac(_digest, _hmacBlockSize);
//     hmac.init(KeyParameter(prk));

//     final output = Uint8List(outputLength);
//     var current = Uint8List(0);
//     var generatedLength = 0;
//     var round = 1;

//     while (generatedLength < outputLength) {
//       final roundInput = Uint8List(current.length + info.length + 1)
//         ..setRange(0, current.length, current)
//         ..setRange(current.length, current.length + info.length, info)
//         ..[current.length + info.length] = round;

//       current = hmac.process(roundInput);
//       final partLength =
//           min(outputLength - generatedLength, _digest.digestSize);
//       output.setRange(generatedLength, generatedLength + partLength, current);
//       generatedLength += partLength;
//       round++;
//     }

//     return output;
//   }

//   static Uint8List hmacAad(Uint8List key, Uint8List message, Uint8List aad) {
//     if (aad.length != 32) {
//       throw Exception('AAD associated data must be 32 bytes');
//     }
//     final combined = Uint8List.fromList(aad + message);
//     final hmac = HMac(SHA256Digest(), 64)..init(KeyParameter(key));
//     return hmac.process(combined);
//   }

//   static Future<Uint8List> chacha20Decrypt(
//     Uint8List key,
//     Uint8List nonce,
//     Uint8List ciphertext,
//   ) async {
//     final algorithm =
//         cryptography.Chacha20(macAlgorithm: cryptography.MacAlgorithm.empty);
//     final secretBox = cryptography.SecretBox(
//       ciphertext,
//       nonce: nonce,
//       mac: cryptography.Mac.empty,
//     );
//     // Encrypt
//     final result = await algorithm.decrypt(
//       secretBox,
//       secretKey: cryptography.SecretKey(key),
//     );

//     return Uint8List.fromList(result);
//   }

//   static String unpad(Uint8List padded) {
//     final unpaddedLen = ByteData.sublistView(padded, 0, 2).getUint16(0);
//     final unpadded = padded.sublist(2, 2 + unpaddedLen);
//     if (unpaddedLen < 1 ||
//         unpaddedLen > 65535 ||
//         unpadded.length != unpaddedLen ||
//         padded.length != 2 + calcPaddedLen(unpaddedLen)) {
//       throw Exception('Invalid padding');
//     }
//     final decoded = utf8.decode(unpadded);
//     debugPrint(jsonDecode(decoded).toString());
//     return decoded;
//   }

//   static int calcPaddedLen(int len) {
//     if (len < 1) throw Exception('Expected positive integer');
//     if (len <= 32) return 32;
//     final nextPower = 1 << ((len - 1).bitLength);
//     final chunk = nextPower <= 256 ? 32 : nextPower ~/ 8;
//     return chunk * ((len - 1) ~/ chunk + 1);
//   }
// }
