import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:kepler/kepler.dart';
import 'package:pointycastle/export.dart';

/// Encrypted Direct Message
class Nip04Service {
  const Nip04Service();

  String encryptNip04({
    required String content,
    required String peerPubkey,
    required String privateKey,
  }) {
    return _encrypt(privateKey, '02$peerPubkey', content);
  }

  String decryptNip04({
    required String content,
    required String peerPubkey,
    required String privateKey,
  }) =>
      _decryptContent1WithPrivateKey(
        content: content,
        peerPubkey: peerPubkey,
        privateKey: privateKey,
      );
}

String _encrypt(String privateKey, String publicKey, String plainText) {
  final uintInputText = const Utf8Encoder().convert(plainText);
  final encryptedString = _encryptRaw(
    privateKey,
    publicKey,
    uintInputText,
  );
  return encryptedString;
}

String _encryptRaw(
  String privateKey,
  String publicKey,
  Uint8List uintInputText,
) {
  final secretIV = Kepler.byteSecret(privateKey, publicKey);
  final key = Uint8List.fromList(secretIV[0]);

  // generate iv  https://stackoverflow.com/questions/63630661/aes-engine-not-initialised-with-pointycastle-securerandom
  final fr = FortunaRandom();
  final sGen = Random.secure();
  fr.seed(
    KeyParameter(
      Uint8List.fromList(List.generate(32, (_) => sGen.nextInt(255))),
    ),
  );
  final iv = fr.nextBytes(16);

  final CipherParameters params = PaddedBlockCipherParameters(
    ParametersWithIV(KeyParameter(key), iv),
    null,
  );

  final cipherImpl =
      PaddedBlockCipherImpl(PKCS7Padding(), CBCBlockCipher(AESEngine()));

  cipherImpl.init(
    true, // means to encrypt
    params as PaddedBlockCipherParameters<CipherParameters?, CipherParameters?>,
  );

  // allocate space
  final outputEncodedText = Uint8List(uintInputText.length + 16);

  var offset = 0;
  while (offset < uintInputText.length - 16) {
    offset += cipherImpl.processBlock(
      uintInputText,
      offset,
      outputEncodedText,
      offset,
    );
  }

  //add padding
  offset +=
      cipherImpl.doFinal(uintInputText, offset, outputEncodedText, offset);
  final finalEncodedText = outputEncodedText.sublist(0, offset);

  final stringIv = base64.encode(iv);
  var outputPlainText = base64.encode(finalEncodedText);
  outputPlainText = '$outputPlainText?iv=$stringIv';
  return outputPlainText;
}

String _decryptContent1WithPrivateKey({
  required String content,
  required String peerPubkey,
  required String privateKey,
}) {
  final ivIndex = content.indexOf('?iv=');
  if (ivIndex <= 0) {
    if (kDebugMode) {
      print('Invalid content for dm, could not get ivIndex: $content');
    }
    return '';
  }
  final iv = content.substring(ivIndex + '?iv='.length, content.length);
  final encString = content.substring(0, ivIndex);
  try {
    return _decrypt(privateKey, '02$peerPubkey', encString, iv);
  } catch (e) {
    return '';
  }
}

// pointy castle source https://github.com/PointyCastle/pointycastle/blob/master/tutorials/aes-cbc.md
// https://github.com/bcgit/pc-dart/blob/master/tutorials/aes-cbc.md
// 3 https://github.com/Dhuliang/flutter-bsv/blob/42a2d92ec6bb9ee3231878ffe684e1b7940c7d49/lib/src/aescbc.dart

/// Decrypt data using self private key
String _decrypt(
  String privateString,
  String publicString,
  String b64encoded, [
  String b64IV = '',
]) {
  final deData = base64.decode(b64encoded);
  final rawData = _decryptRaw(privateString, publicString, deData, b64IV);
  return const Utf8Decoder().convert(rawData.toList());
}

Uint8List _decryptRaw(
  String privateString,
  String publicString,
  Uint8List cipherText, [
  String b64IV = '',
]) {
  final byteSecret = Kepler.byteSecret(privateString, publicString);
  final secretIV = byteSecret;
  final key = Uint8List.fromList(secretIV[0]);
  final iv =
      b64IV.length > 6 ? base64.decode(b64IV) : Uint8List.fromList(secretIV[1]);

  if (kIsWeb) {
    //...
  }

  final CipherParameters params = PaddedBlockCipherParameters(
    ParametersWithIV(KeyParameter(key), iv),
    null,
  );

  final cipherImpl =
      PaddedBlockCipherImpl(PKCS7Padding(), CBCBlockCipher(AESEngine()));

  cipherImpl.init(
    false,
    params as PaddedBlockCipherParameters<CipherParameters?, CipherParameters?>,
  );
  final finalPlainText = Uint8List(cipherText.length); // allocate space

  var offset = 0;
  while (offset < cipherText.length - 16) {
    offset +=
        cipherImpl.processBlock(cipherText, offset, finalPlainText, offset);
  }
  //remove padding
  offset += cipherImpl.doFinal(cipherText, offset, finalPlainText, offset);
  return finalPlainText.sublist(0, offset);
}
